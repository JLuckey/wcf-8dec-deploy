class CreateSimsInstrumentConfigurations < ActiveRecord::Migration
  def change
    create_table :sims_instrument_configurations do |t|
      t.integer "id"
      t.integer "submission_id"
      t.integer "seq_num"
      t.string "analyzer_type"
      t.string "spectrometer_manufacturer"
      t.string "manufacturer_model_number"
      t.string "experiment_type"
      t.string "placeholder_for_ion_guns_ptd"   , :limit => 10
      t.text   "charge_control_cond_proced"   
      t.string "sample_rotation_y_n"   , :limit => 1
      t.decimal "sample_rotation_rate_rpm"   , :precision => 10, :scale => 0
      t.text    "oxygen_flood_source"   
      t.decimal "oxygen_flood_pressure_pa"   , :precision => 10, :scale => 0
      t.text    "other_flood_source"   
      t.decimal "other_flood_pressure_pa"   , :precision => 10, :scale => 0
      t.text    "unique_inst_features_used"   
      t.decimal "energy_accept_window_ev"   , :precision => 10, :scale => 0
      t.text    "detector_description"   
      t.decimal "live_time_pct"   , :precision => 10, :scale => 0
      t.decimal "sample_bias_ev"   , :precision => 10, :scale => 0
      t.integer "spec_normal_to_analyzer_deg"   
      t.timestamps
    end
  end
end
