---
layout: post
categories: fog
---

```ruby
# test/test_helper.rb
Fog.mock!
Fog::Storage
  .new(provider: 'AWS', aws_access_key_id: 'XXX', aws_secret_access_key: 'XXX')
  .directories
  .create key: 'foo'
```

```ruby
# config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: Rails.configuration.secrets.aws_access_key_id,
    aws_secret_access_key: Rails.configuration.secrets.aws_secret_access_key,
  }
end
```

```yaml
# config/secrets.yml
test:
  aws_access_key_id: AAA
  aws_secret_access_key: BBB
production:
  aws_access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  aws_secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
```

```
Excon::Errors::NotFound:         Excon::Errors::NotFound: Expected(200) <=> Actual(404 Not Found)

            app/controllers/attachments_controller.rb:13:in `create'
            app/controllers/main_controller.rb:28:in `set_current_time_zone'
            test/features/attachments_test.rb:19:in `block (2 levels) in <top (required)>'
```

```ruby
# test/test_helper.rb
Fog::Storage
  .new(DocumentUploader.fog_credentials)
  .directories
  .create key: DocumentUploader.fog_directory
```
