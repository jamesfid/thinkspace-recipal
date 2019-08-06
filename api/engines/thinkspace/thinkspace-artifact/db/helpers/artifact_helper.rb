def create_artifact_bucket(*args)
  options = args.extract_options!
  bucket  = @seed.new_model(:artifact, :bucket, options)
  @seed.create_error(bucket) unless bucket.save
  bucket
end