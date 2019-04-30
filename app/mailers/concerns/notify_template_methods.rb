module NotifyTemplateMethods
  def template_name(template_name)
    template_id = template_ids.fetch(template_name)
    set_template(template_id)
  end

  def template_ids
    @template_ids ||= Rails.configuration.govuk_notify_templates
  end
end
