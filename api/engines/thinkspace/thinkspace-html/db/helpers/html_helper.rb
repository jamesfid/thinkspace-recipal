def create_html_content(*args)
  options = args.extract_options!
  content = @seed.new_model(:html, :content, options)
  @seed.create_error(content)  unless content.save
  content
end

def html_get_sample_content(sample_id, options={})
  sample_method = "html_sample_content_#{sample_id.to_s}".to_sym
  return nil  unless Object.respond_to?(sample_method, true)
  self.send(sample_method, options)
end

def html_format_sample_content(content)
  return '' if content.blank?
  content.gsub(/\s\s+/, ' ').gsub("\n", ' ')
end

