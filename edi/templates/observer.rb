# This observer defines all the event-based hooks for the Exel Clorox EDI workflow
class Api::Edi::Exel::Clorox::EdiObserver < ActiveRecord::Observer
  include Edi::ObserverUtils

  observe :shipment, OutboundStockTransfer::Unit

  Exel944Shipment = Api::Edi::Exel::Clorox::RedPrairie::EdiOutbound944Shipment
  Exel944Transfer = Api::Edi::Exel::Clorox::RedPrairie::EdiOutbound944StockTransfer

  ERROR_MESSAGES = {
    :shipment_944 => "Shipment could not be shipped because the EDI 944 could not be queued"
  }

  def shipment_updated(shipment)
    return unless shipment.site.edi_workflow_exel_clorox
    return unless edi_customer_trigger_for(shipment.site_id, shipment.customer_id, Exel944Shipment)

    after_ship(shipment) if shipment.shipped_changed? && shipment.shipped?
  end

  def create(unit)
    return unless unit.site.edi_workflow_exel_clorox
    return unless edi_customer_trigger_for(unit.site_id, unit.transfer_pallet.project.try(:customer_id), Exel944Transfer)

    edi = Exel944Transfer.create!(:outbound_transfer_unit => unit, :site => unit.site)
    edi.make_queued
  end

private
  def after_ship shipment
    added_errors = false
    Exel944Shipment.eligible_unit_shipments_for(shipment).each do |us|
      edi_944 = Exel944Shipment.create! :unit_shipment => us, :site => shipment.site
      edi_944.make_queued

      unless added_errors
        copy_error_messages edi_944, shipment, ERROR_MESSAGES[:shipment_944]
        added_errors = true
      end
    end
  end
end
