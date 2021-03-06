require 'test_helper'

class LegalDocumentTest < ActiveSupport::TestCase
  def test_valid_legal_document_fixture_is_valid
    assert valid_legal_document.valid?, proc { valid_legal_document.errors.full_messages }
  end

  def test_duplicate_legal_docs 
    assert LegalDocument.remove_duplicates
  end

  private

  def valid_legal_document
    legal_documents(:one)
  end
end

