if Rails.env.development?
  Footnotes.setup do |f|
    f.enabled = true
  end
end
