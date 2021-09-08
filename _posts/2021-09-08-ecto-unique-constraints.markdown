---
layout: post
title: Validation of Unique Constraints in Ecto
tags: [elixir, phoenix, ecto]
---

I've started playing with [Phoenix](https://phoenixframework.org) and, by
extension, [Ecto](https://hexdocs.pm/ecto/Ecto.html). Coming from
[Rails](https://rubyonrails.org) and [Active
Record](https://api.rubyonrails.org/classes/ActiveRecord/Base.html), one
interesting change has been the handling of uniqueness constraints. While
Active Record does provide
[`#validates_uniqueness_of`](https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of),
it is implemented in a way that is vulnerable to race conditions. In most cases
it works well enough to give you actual validation errors, but it is
nevertheless possible for validation to pass and a duplicate row to be inserted
into the database.

Of course, any reasonably sane database will provide its own uniqueness
constraints, so, assuming we use them, instead of bad data actually being
written, we will get an `ActiveRecord::RecordNotUnique` exception when we call
`ActiveRecord#save`. We can catch this exception ourselves and add validation
errors to the model to provide a user experience that is no different than any
other validation error, but that means more work for us, the programmer.

Ecto, on the other hand takes care of all this for us. Rather than check in
advance for a violation, Ecto tries to perform the operation. If it catches a
uniqueness constraint violation, it tries to infer the attribute(s) invovled,
and adds the appropriate validation errors.

There are only two gotchas to bear in mind.

1. Validation of uniqueness constraints can only happen after the `INSERT` or
   `UPDATE` operation is attempted. If there are other validation errors, the
   uniqueness validation won't be performed because the operation will have
   been aborted before hitting the database.
2. Turning constraint violations into validation errors is contingent on Ecto
   being able to map the actual violation to a uniqueness constraint in the
   Ecto schema. This mapping is usually inferred from the name of the unique
   index in the database, but it can be made explicit by passing `:name` to
   [`Ecto.Migration.unique_index/3`](https://hexdocs.pm/ecto_sql/Ecto.Migration.html#unique_index/3)
   and
   [`Ecto.Changeset.unique_constraint/3`](https://hexdocs.pm/ecto/3.7.0/Ecto.Changeset.html#unique_constraint/3).

## setup

I'm working on an application that takes in sensor readings from individual
nodes and stores them in a [PostgreSQL](https://postgresql.org) database. The
nodes are grouped together into clusters. Clusters and nodes each have a name
attribute. Cluster names must be unique. Node names must also be unique but
only within the scope their respective cluster. This gives us the following
schema:

```elixir
defmodule Thermostat.Cluster do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clusters" do
    field :name, :string
    has_many :nodes, Thermostat.Node

    timestamps()
  end

  @doc false
  def changeset(cluster, attrs) do
    cluster
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end

defmodule Thermostat.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :name, :string
    belongs_to :cluster, Thermostat.Cluster

    timestamps()
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name, :cluster_id])
  end
end
```

There's nothing remarkable about any of this, but I will draw your attention to
the `unique_constraint` in `Node`. Because the name only needs to be unique
within the cluster, we define the constraint on `[:name, :cluster_id]`. We put
`:name` first because that is the field to which the validation error should be
attached if the constraint is violated.

Now let's move on to the corresponding migrations.

```elixir
defmodule Thermostat.Repo.Migrations.CreateClusters do
  use Ecto.Migration

  def change do
    create table(:clusters) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:clusters, :name)
  end
end

defmodule Thermostat.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :name, :string, null: false
      add :cluster_id, references(:clusters, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:nodes, [:cluster_id, :name])
  end
end
```

As with the schemas, there's nothing remarkable about these migrations, but
this time I want to draw your attention to the `unique_index` in `CreateNodes`.
The constraint is on the `cluster_id` and `name` columns, however, I have
reversed the order of the columns in the index compared to how they were
defined in the schema constraint. Why?

## Indexing

When indexing columns in a database, the order in which the columns are
specified can have an impact on how useful the column is. In this
application, when we fetch nodes from the database we will be sorting them by
name, but we will only be fetching nodes belonging to a specific cluster. We're
probably going to see queries like this:

```sql
SELECT * FROM nodes WHERE "cluster_id" = ? ORDER BY name
```

This is where the order of the columns comes into play. Assuming the database
is large enough for this to matter, PostgreSQL's query planner will look for an
index to help out. In general, if one column is likely to have more specific
constraints in a query than another column, you want that column to appear
earlier in the index because it means the matching rows will already be grouped
together. In this case, the `WHERE "cluster_id" = ?` clause is more specific
than the `ORDER BY name` clause.

If we had defined the index with the `name` column first, the query planner
will not even use the index because while the nodes will be in the right order
within the index, the records that match the `cluster_id` filter could be
spread across the entire index. If we put `cluster_id` first, PostgreSQL knows
that all of the matching rows will be adjacent to each other in the index, and
because the index has a secondary sort key on `name`, those results will
already be in the correct order.

To see this in action, I created the two tables described above and populated
the database with 1,000 clusters, each with 1,000 nodes; the nodes table has
1,000,000 rows total.

I then created the following index:

```sql
CREATE UNIQUE INDEX idx_nodes_name_cluster_id ON nodes(name, cluster_id)
```

I then ran the following `EXPLAIN ANALYZE` query. (I did this several times to
warm up the database and included the results of the final run).

```
EXPLAIN ANALYZE SELECT * FROM nodes WHERE cluster_id = 500 ORDER BY name;
                                                          QUERY PLAN                                                           
-------------------------------------------------------------------------------------------------------------------------------
 Gather Merge  (cost=13486.40..13583.24 rows=830 width=20) (actual time=48.372..50.292 rows=1000 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Sort  (cost=12486.38..12487.42 rows=415 width=20) (actual time=41.039..41.058 rows=333 loops=3)
         Sort Key: name
         Sort Method: quicksort  Memory: 71kB
         Worker 0:  Sort Method: quicksort  Memory: 56kB
         Worker 1:  Sort Method: quicksort  Memory: 25kB
         ->  Parallel Seq Scan on nodes  (cost=0.00..12468.33 rows=415 width=20) (actual time=27.367..39.770 rows=333 loops=3)
               Filter: (cluster_id = 500)
               Rows Removed by Filter: 333000
 Planning Time: 0.070 ms
 Execution Time: 50.360 ms
(13 rows)

Time: 51.213 ms
```

As expected, the query planner ignored the index entirely. It performed a
parallelized sequential scan of the nodes table and merged and sorted the
results. Query execution took 50.36ms.

Next, I dropped the `idx_nodes_name_cluster_id` index and created this index instead:

```sql
CREATE UNIQUE INDEX idx_nodes_cluster_id_name ON nodes(cluster_id, name)
```

As before, I ran the `EXPLAIN ANALYZE` query several times and included the
final run below.

```
EXPLAIN ANALYZE SELECT * FROM nodes WHERE cluster_id = 500 ORDER BY name;
                                                                QUERY PLAN                                                                
------------------------------------------------------------------------------------------------------------------------------------------
 Index Scan using idx_nodes_cluster_id_name on nodes  (cost=0.42..1676.81 rows=997 width=20) (actual time=0.017..0.189 rows=1000 loops=1)
   Index Cond: (cluster_id = 500)
 Planning Time: 0.061 ms
 Execution Time: 0.230 ms
(4 rows)

Time: 0.867 ms
```

This time, the query planner performed a simple index scan. It didn't even have
to sort the results because it knew they were already in the correct order
coming out of the index. Query exectuion only took 0.23ms.

The order in which you specify the columns on a multicolumn index matters.

## Validation

So this takes as back to Ecto. Ecto is smart enough to turn violations of
uniqueness constraints into validation errors, but it can only do this if it
can figure out find a matching uniqueness constraint on the `Ecto.Changeset`.
Unfortunately, if the order of columns on the index don't match the order on
the uniqueness constraint of the changeset, Ecto gets confused. Instead of
returning `{:error, %Ecto.Changeset}` with validation errors, it raises an
`Ecto.ConstraintError`.

How does this present in practice? Let's start by inserting a single cluster
and a single node into the database. We assign the cluster to `cluster` inside
the IEx session for use when inserting nodes. (NB: I have aliased
`Thermostat.Repo`, `Thermostat.Cluster`, and `Thermostat.Node` inside the IEx
session to cut down on typing.)

```elixir
iex(1)> alias Thermostat.{Repo, Cluster, Node}
[Thermostat.Repo, Thermostat.Cluster, Thermostat.Node]
iex(2)> cluster = Repo.insert!(%Cluster{name: "cluster-0"})
%Thermostat.Cluster{
  __meta__: #Ecto.Schema.Metadata<:loaded, "clusters">,
  id: 1,
  inserted_at: ~N[2021-09-08 18:49:09],
  name: "cluster-0",
  nodes: #Ecto.Association.NotLoaded<association :nodes is not loaded>,
  updated_at: ~N[2021-09-08 18:49:09]
}
iex(3)> cluster |> Ecto.build_assoc(:nodes) |> Node.changeset(%{name: "node-0"}) |> Repo.insert()
{:ok,
 %Thermostat.Node{
   __meta__: #Ecto.Schema.Metadata<:loaded, "nodes">,
   cluster: #Ecto.Association.NotLoaded<association :cluster is not loaded>,
   cluster_id: 1,
   id: 1,
   inserted_at: ~N[2021-09-08 18:57:49],
   name: "node-0",
   updated_at: ~N[2021-09-08 18:57:49]
 }}
```

Now that we have an existing cluster and node, we deliberately try to violate
the uniqueness constraint by inserting a new node with the same name as the
existing node and beloinging to the same cluster.

```elixir
iex(4)> cluster |> Ecto.build_assoc(:nodes) |> Node.changeset(%{name: "node-0"}) |> Repo.insert()
[debug] QUERY ERROR db=1.2ms queue=0.8ms idle=413.2ms
INSERT INTO "nodes" ("cluster_id","name","inserted_at","updated_at") VALUES ($1,$2,$3,$4) [1, "node-0", ~N[2021-09-08 19:03:19], ~N[2021-09-08 19:03:19]]
** (Ecto.ConstraintError) constraint error when attempting to insert struct:

    * nodes_cluster_id_name_index (unique_constraint)

If you would like to stop this constraint violation from raising an
exception and instead add it as an error to your changeset, please
call `unique_constraint/3` on your changeset with the constraint
`:name` as an option.

The changeset defined the following constraints:

    * nodes_name_cluster_id_index (unique_constraint)

    (ecto 3.7.1) lib/ecto/repo/schema.ex:783: anonymous fn/4 in Ecto.Repo.Schema.constraints_to_errors/3
    (elixir 1.12.2) lib/enum.ex:1582: Enum."-map/2-lists^map/1-0-"/2
    (ecto 3.7.1) lib/ecto/repo/schema.ex:768: Ecto.Repo.Schema.constraints_to_errors/3
    (ecto 3.7.1) lib/ecto/repo/schema.ex:749: Ecto.Repo.Schema.apply/4
    (ecto 3.7.1) lib/ecto/repo/schema.ex:367: anonymous fn/15 in Ecto.Repo.Schema.do_insert/4
```

As you can see, Ecto has already guessed that we might want this constraint
violation to treated as a validation error. It just doesn't realize that the
`nodes_cluster_id_name_index` is related to the schema's unique constraint on
`[:name, :cluster_id]`. Nevertheless, it tells us how to fix the problem in the
schema by using the `:name` option. We can make the following change to the
Node schema:

```elixir
defmodule Thermostat.Node do
   # …
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name, :cluster_id], name: :nodes_cluster_id_name_index)
  end
end
```

With that change made, we can recompile and try inserting the duplicate row again.

```elixir
iex(5)> recompile()
Compiling 1 file (.ex)
:ok
iex(6)> cluster |> Ecto.build_assoc(:nodes) |> Node.changeset(%{name: "node-0"}) |> Repo.insert()
[debug] QUERY ERROR db=4.1ms idle=1104.8ms
INSERT INTO "nodes" ("cluster_id","name","inserted_at","updated_at") VALUES ($1,$2,$3,$4) RETURNING "id" [1, "node-0", ~N[2021-09-08 19:00:45], ~N[2021-09-08 19:00:45]]
{:error,
 #Ecto.Changeset<
   action: :insert,
   changes: %{cluster_id: 1, name: "node-0"},
   errors: [
     name: {"has already been taken",
      [constraint: :unique, constraint_name: "nodes_cluster_id_name_index"]}
   ],
   data: #Thermostat.Node<>,
   valid?: false
 >}
```

Huzzah! Instead of raising an exception, `Repo.insert/1` returned `{:error,
%Ecto.Changeset}` complete with a jaunty validation error on the `:name`
attribute. Best of all, the manner in which we arrived with this error was
bulletproof. Unlike in Active Record, this uniqueness validation does not
suffer from a race conditions.
