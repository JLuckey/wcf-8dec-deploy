class FieldMaster < ActiveRecord::Base

  def self.get_form_fields(form_id)
    form_rec = Form.find_by_name(form_id)
    if form_rec
			#  execute field_master equivalent query
			FieldMaster.find_by_sql(
										"select f.name, ff.seqnum, fm.id as field_mast_id, fm.wecf_table_name, fm.wecf_field_name, fm.wecf_data_type, " +
       							"ff.designator as contrib_form_id, ff.field_label as contrib_form_prompt, ff.help_text,                       " +
       							"ff.html_widget, ff.widget_height as html_widget_height, ff.widget_width as html_widget_width                 " +
										"from  forms f, form_fields ff, field_masters fm    " +
										"where f.name = '#{form_id}'					              " +
										"and   f.id = ff.forms_id                           " +
										"and   ff.field_masters_id = fm.id                  " +
										"order by ff.seqnum " )
    else
      #  do regular field_master query
      FieldMaster.find(:all, :conditions => ["wecf_table_name = ? and show_field = 'y'", form_id], :order => "seq_on_wecf_page")
    end
end  


#  DevNotes:
#    Add an explanation of how get_form_fields logic works & why it's needed ???JL
#    Field comparision between form_fields & field_masters
#    3/18/2008 10:44
#
#  myrec = HtmlFormRec.new(
#	 fm_rec.wecf_field_name,                     same
#	 fm_rec.contrib_form_prompt,								 field_label
#	 fm_rec.html_widget,												 same
#  fm_rec.html_widget_width,                   same
#	 fm_rec.html_widget_height,                  same
#	 fm_rec.help_text,                           same
#	 fm_rec.contrib_form_id,                     designator

#	 data_object_in.class.to_s, data_object_in.id,
#  data_object_in[fm_rec.wecf_field_name] )

#	CREATE TABLE `form_fields` (
#  `id` int(10) unsigned NOT NULL auto_increment,
#  `forms_id` int(10) unsigned NOT NULL default '0',
#  `seqnum` int(10) unsigned default NULL,
#  `field_label` varchar(255) default NULL,
#  `designator` varchar(10) default NULL,
#  `help_text` text,
#  `field_masters_id` int(10) unsigned default NULL,
#  `html_widget` varchar(45) default NULL,
#  `widget_width` int(10) unsigned default NULL,
#  `widget_height` int(10) unsigned default NULL,
#  PRIMARY KEY  (`id`)

end
