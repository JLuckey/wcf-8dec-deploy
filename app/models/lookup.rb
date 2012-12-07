class Lookup < ActiveRecord::Base

  def self.get_listbox_choices(table, field)
    a = Array.new
    q_result = Lookup.find_by_sql ["SELECT field_value FROM lookups WHERE table_name = ? AND field_name = ?", table, field]
    q_result.each {|q| a.push(q.field_value)}
    return a
  end

end
