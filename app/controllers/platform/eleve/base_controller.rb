module Platform
  module Eleve
    class BaseController < Platform::BaseController
      before_action :require_eleve!
    end
  end
end
