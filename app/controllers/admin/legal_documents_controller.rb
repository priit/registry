module Admin
  class LegalDocumentsController < BaseController
    load_and_authorize_resource

    def show
      @ld = LegalDocument.find(params[:id])
      filename = @ld.path.split('/').last
      file = File.open(@ld.path).read

      if file
        send_data file, filename: filename
      else
        flash[:notice] = I18n.t('legal_doc_not_found')
        redirect_to [:admin, @ld.documentable]
      end
    end
  end
end
