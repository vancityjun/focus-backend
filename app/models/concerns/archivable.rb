module Archivable
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :archive, :unarchive

    scope :archived, -> { where(archived: true)}
    scope :active, -> { where("#{self.table_name}.archived IS NULL OR #{self.table_name}.archived IS false") }
  end

  def active?
    !archived?
  end

  def archive!
    validate_for_archivable

    run_callbacks :archive do
      self.archived = true,
      self.archived_at = Time.current if respond_to?(:archived_at)
      run_callbacks :commit do
        save(validate: false)
      end
    end
  end

  def archive
    archive!
  rescue Archivable::RecordNotFound, Archivable::InvalidArchivedState => exception
    errors.clear
    errors.add :base, exception.message
    false
  end

  def unarchive!
    validate_for_unarchivable

    run_callbacks :archive do
      unarchive_attrs =
        {
          archived: false,
          archived_at: nil
        }.delete_if { |key, _val| !respond_to?(key) }
      run_callbacks :commit do
        update_columns unarchive_attrs
      end
    end
  end

  def unarchive
    unarchive!
  rescue Archivable::RecordNotFound, Archivable::InvalidArchivedState => exception
    errors.clear
    errors.add :base, exception.message
    false
  end

private

  def validate_for_archivable
    raise Archivable::RecordNotFound.new('This record is not exist in database.') unless persisted?
    raise Archivable::InvalidArchivedState.new('This record is already archived.') if archived?
  end

  def validate_for_unarchivable
    raise Archivable::RecordNotFound.new('This record is not exist in database.') unless persisted?
    raise Archivable::InvalidArchivedState.new('This record is not archived.') unless archived?
  end

  class Archivable::RecordNotFound < StandardError
  end

  class Archivable::InvalidArchivedState < StandardError
  end
end
