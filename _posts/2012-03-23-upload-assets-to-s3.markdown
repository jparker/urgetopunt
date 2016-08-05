---
title: Rake Task to Upload Assets to S3 for Cloudfront
layout: post
---

**UPDATE 2016-07-29:** There are [better ways](https://devcenter.heroku.com/articles/using-amazon-cloudfront-cdn#adding-cloudfront-to-rails)
for serving static assets through a CDN from an application hosted on Heroku. This procedure described below is outdated.

In an application serving static assets from
[Cloudfront](http://aws.amazon.com/cloudfront), I'm using
[Fog](http://fog.io) and the following Rake task to upload precompiled
assets and remove stale ones.

```ruby
# RAILS_ROOT/lib/tasks/assets.rake
namespace :assets do
  desc 'Precompile assets and upload to S3'
  task :upload, [:noop] => ['assets:clean', 'assets:precompile'] do |_, args|
    args.with_defaults(noop: false)

    Fog.credentials_path = "#{Rails.root}/config/fog_credentials.yml"

    Dir.chdir("#{Rails.root}/public") do
      assets = FileList['assets',"assets/**/*"].inject({}) do |hsh, path|
        if File.directory? path
          hsh.update("#{path}/" => :directory)
        else
          hsh.update(path => OpenSSL::Digest::MD5.hexdigest(File.read(path)))
        end
      end
      raise 'public/assets is empty: aborting' if assets.size <= 1

      fog = Fog::Storage.new(provider: 'AWS')
      # Replace ASSETS_BUCKET with the name of the S3 bucket for storing assets
      bucket = fog.directories.get(ASSETS_BUCKET)

      assets.each do |file, etag|
        case etag
        when :directory
          puts "Directory #{file}"
          bucket.files.create(key: file, public: true) unless args[:noop]
        when bucket.files.get(file).try(:etag)
          puts "Skipping #{file} (identical)"
        else
          puts "Uploading #{file}"
          bucket.files.create(key: file, public: true, body: File.open(file), cache_control: "max-age=#{1.month.to_i}") unless args[:noop]
        end
      end

      bucket.files.each do |object|
        unless assets.has_key? object.key
          puts "Removing #{object.key} (no longer exists)"
          object.destroy unless args[:noop]
        end
      end
    end
  end
end
```

The task depends on <tt>assets:clean</tt> and
<tt>assets:precompile</tt>, so each time it runs
<tt>public/assets</tt> is cleaned out and the assets are recompiled.
The task then calculates the etag (MD5 checksum) of each file, compares
it to the etag of the file on S3, and, if it's different, copies the
asset up. If the etags are the same, it skips the file. Finally, after
uploading everything, the task runs through the contents of the asset
bucket, and removes any files that didn't also exist in
<tt>public/assets</tt> on the local machine. This assumes the bucket
in question is only being used to serve assets for the current
application. **Do not use this task as is if you are using the bucket to
serve additional content!**

As a sanity check, the task aborts before making any changes if
<tt>public/assets</tt> is empty.

This task also takes advantage of Rake's command line arguments feature
to let you run the task in "no-op" mode. In this mode, assets are still
removed locally and precompiled, but changes to S3 are reported but not
actually carried out. To run it in no-op mode, append
<kbd>[noop]</kbd> (really, anything in brackets) to the task name on
invocation:

```
$ rake assets:upload[noop]    # runs in no-op mode
$ rake assets:upload          # runs in dangerous mode
```
