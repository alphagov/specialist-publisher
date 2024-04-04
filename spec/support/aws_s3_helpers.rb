module AwsHelpers
  def mock_s3_bucket(client, bucket)
    client.stub_responses(:get_object, lambda { |context|
                                         obj = bucket[context.params[:key]]
                                         obj || "NoSuchKey"
                                       })
    client.stub_responses(:put_object, lambda { |context|
      bucket[context.params[:key]] = { body: context.params[:body] }
      {}
    })
  end
end

RSpec.configuration.include AwsHelpers
