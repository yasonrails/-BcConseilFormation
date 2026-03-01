module Platform
  module Admin
    class BaseController < Platform::BaseController
      before_action :require_admin!
    end
  end
end
