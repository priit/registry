class Registrar
  class ProfileController < BaseController
    skip_authorization_check

    def show
      @registrar = current_user.registrar
    end
  end
end
