module AttachmentsHelper
  def attachments_with_size(attachments)
    return [] unless attachments

    attachments&.map do |at|
      (at.original_filename || at.attachment_type) + " (#{number_to_human_size(at.document.blob.byte_size)})"
    end
  end
end
