class Api::Edi::Exel::Clorox::RedPrairie::EdiOutbound944Shipment < EdiOutbound
  include ::Edi::Push
  belongs_to :unit_shipment, :foreign_key => :source_id

  def self.eligible_unit_shipments_for(shipment)
    shipment.all_unit_shipments.find(:all, :include => [:pallet, :sku],
      :conditions => ["skus.is_finished_good = :fg AND skus.is_subcomponent = :sub AND pallets.job_id IS NOT NULL", {:fg => true, :sub => false}])
  end

  def self.view_model
    "shipments"
  end

  def prevent_queued_status_no_edi_mapping
    #overriding to suppress validation
  end

  def skip_status_validation
    @skip_status_validation = true
  end

  def source
    self.unit_shipment
  end

  def set_customer
    self.customer_id = self.unit_shipment.shipment.customer_id
  end

  def view_model
    self.unit_shipment.try(:shipment)
  end

  # ****************************************************************
  # start Pushmethods

  def ca_certificate
    self.site.edi_configuration.ca_certificate_for_outbound_944_data
  end
  # ****************************************************************
  # end Push methods

  def date
    self.unit_shipment.shipment.actual_ship_at.try(:strftime, "%Y-%m-%d")
  end

  def job_id
    self.unit_shipment.pallet.job_id
  end

  def order_number
    self.unit_shipment.pallet.job.project.code
  end

  def pallet_number
    self.unit_shipment.pallet.number
  end

  def part_number
    self.unit_shipment.sku.code
  end

  def quantity
    self.unit_shipment.quantity
  end

  def lot_code
    self.unit_shipment.lot_code
  end

  def expiry_date
    self.unit_shipment.expiry_date
  end

  def part_uom
    self.unit_shipment.sku.unit_of_measure
  end
end
