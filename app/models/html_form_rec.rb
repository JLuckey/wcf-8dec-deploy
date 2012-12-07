class HtmlFormRec
  attr_reader :field_name, :field_label, :display_widget, :display_widget_width, :display_widget_height, :help_text, :model_name, :record_id, :contrib_form_id, :field_data

  def initialize(field_name, field_label, display_widget, display_widget_width, display_widget_height, help_text, model_name, record_id, contrib_form_id, field_data )
    @field_name             = field_name
    @field_label            = field_label
    @display_widget         = display_widget
    @display_widget_width   = display_widget_width
    @display_widget_height  = display_widget_height
    @help_text              = help_text
    @model_name             = model_name
    @record_id              = record_id
    @contrib_form_id        = contrib_form_id
    @field_data             = field_data
  end

end