require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index
      render plain: "ok"
    end
  end

  describe "#after_sign_in_path_for" do
    it "redirects to root" do
      expect(controller.send(:after_sign_in_path_for, double)).to eq(root_path)
    end
  end

  describe "#after_sign_out_path_for" do
    it "redirects to root" do
      expect(controller.send(:after_sign_out_path_for, double)).to eq(root_path)
    end
  end

  describe "#configure_permitted_parameters" do
    it "permits username on devise controllers" do
      sanitizer = instance_double(Devise::ParameterSanitizer)
      allow(controller).to receive(:devise_parameter_sanitizer).and_return(sanitizer)
      expect(sanitizer).to receive(:permit).with(:sign_up, keys: [ :username ])
      expect(sanitizer).to receive(:permit).with(:account_update, keys: [ :username ])

      controller.send(:configure_permitted_parameters)
    end
  end
end
