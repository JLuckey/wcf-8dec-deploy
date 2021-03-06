require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SimsIonSourcesController do

  # This should return the minimal set of attributes required to create a valid
  # SimsIonSource. As you add validations to SimsIonSource, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all sims_ion_sources as @sims_ion_sources" do
      sims_ion_source = SimsIonSource.create! valid_attributes
      get :index
      assigns(:sims_ion_sources).should eq([sims_ion_source])
    end
  end

  describe "GET show" do
    it "assigns the requested sims_ion_source as @sims_ion_source" do
      sims_ion_source = SimsIonSource.create! valid_attributes
      get :show, :id => sims_ion_source.id.to_s
      assigns(:sims_ion_source).should eq(sims_ion_source)
    end
  end

  describe "GET new" do
    it "assigns a new sims_ion_source as @sims_ion_source" do
      get :new
      assigns(:sims_ion_source).should be_a_new(SimsIonSource)
    end
  end

  describe "GET edit" do
    it "assigns the requested sims_ion_source as @sims_ion_source" do
      sims_ion_source = SimsIonSource.create! valid_attributes
      get :edit, :id => sims_ion_source.id.to_s
      assigns(:sims_ion_source).should eq(sims_ion_source)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SimsIonSource" do
        expect {
          post :create, :sims_ion_source => valid_attributes
        }.to change(SimsIonSource, :count).by(1)
      end

      it "assigns a newly created sims_ion_source as @sims_ion_source" do
        post :create, :sims_ion_source => valid_attributes
        assigns(:sims_ion_source).should be_a(SimsIonSource)
        assigns(:sims_ion_source).should be_persisted
      end

      it "redirects to the created sims_ion_source" do
        post :create, :sims_ion_source => valid_attributes
        response.should redirect_to(SimsIonSource.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sims_ion_source as @sims_ion_source" do
        # Trigger the behavior that occurs when invalid params are submitted
        SimsIonSource.any_instance.stub(:save).and_return(false)
        post :create, :sims_ion_source => {}
        assigns(:sims_ion_source).should be_a_new(SimsIonSource)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        SimsIonSource.any_instance.stub(:save).and_return(false)
        post :create, :sims_ion_source => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sims_ion_source" do
        sims_ion_source = SimsIonSource.create! valid_attributes
        # Assuming there are no other sims_ion_sources in the database, this
        # specifies that the SimsIonSource created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        SimsIonSource.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => sims_ion_source.id, :sims_ion_source => {'these' => 'params'}
      end

      it "assigns the requested sims_ion_source as @sims_ion_source" do
        sims_ion_source = SimsIonSource.create! valid_attributes
        put :update, :id => sims_ion_source.id, :sims_ion_source => valid_attributes
        assigns(:sims_ion_source).should eq(sims_ion_source)
      end

      it "redirects to the sims_ion_source" do
        sims_ion_source = SimsIonSource.create! valid_attributes
        put :update, :id => sims_ion_source.id, :sims_ion_source => valid_attributes
        response.should redirect_to(sims_ion_source)
      end
    end

    describe "with invalid params" do
      it "assigns the sims_ion_source as @sims_ion_source" do
        sims_ion_source = SimsIonSource.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SimsIonSource.any_instance.stub(:save).and_return(false)
        put :update, :id => sims_ion_source.id.to_s, :sims_ion_source => {}
        assigns(:sims_ion_source).should eq(sims_ion_source)
      end

      it "re-renders the 'edit' template" do
        sims_ion_source = SimsIonSource.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SimsIonSource.any_instance.stub(:save).and_return(false)
        put :update, :id => sims_ion_source.id.to_s, :sims_ion_source => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested sims_ion_source" do
      sims_ion_source = SimsIonSource.create! valid_attributes
      expect {
        delete :destroy, :id => sims_ion_source.id.to_s
      }.to change(SimsIonSource, :count).by(-1)
    end

    it "redirects to the sims_ion_sources list" do
      sims_ion_source = SimsIonSource.create! valid_attributes
      delete :destroy, :id => sims_ion_source.id.to_s
      response.should redirect_to(sims_ion_sources_url)
    end
  end

end
