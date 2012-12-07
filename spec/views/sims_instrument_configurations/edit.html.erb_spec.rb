require 'spec_helper'

describe "sims_instrument_configurations/edit.html.erb" do
  before(:each) do
    @sims_instrument_configuration = assign(:sims_instrument_configuration, stub_model(SimsInstrumentConfiguration,
      :submission_id => 1,
      :seq_num => 1,
      :analyzer_type => "MyString",
      :spectrometer_manufacturer => "MyString",
      :manufacturer_model_number => "MyString",
      :experiment_type => "MyString"
    ))
  end

  it "renders the edit sims_instrument_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sims_instrument_configurations_path(@sims_instrument_configuration), :method => "post" do
      assert_select "input#sims_instrument_configuration_submission_id", :name => "sims_instrument_configuration[submission_id]"
      assert_select "input#sims_instrument_configuration_seq_num", :name => "sims_instrument_configuration[seq_num]"
      assert_select "input#sims_instrument_configuration_analyzer_type", :name => "sims_instrument_configuration[analyzer_type]"
      assert_select "input#sims_instrument_configuration_spectrometer_manufacturer", :name => "sims_instrument_configuration[spectrometer_manufacturer]"
      assert_select "input#sims_instrument_configuration_manufacturer_model_number", :name => "sims_instrument_configuration[manufacturer_model_number]"
      assert_select "input#sims_instrument_configuration_experiment_type", :name => "sims_instrument_configuration[experiment_type]"
    end
  end
end
