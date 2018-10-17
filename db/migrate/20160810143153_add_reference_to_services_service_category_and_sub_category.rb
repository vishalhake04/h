class AddReferenceToServicesServiceCategoryAndSubCategory < ActiveRecord::Migration
  def change
    add_reference :services,:service_category,index: true, foreign_key: true
    add_reference :services,:service_sub_category,index: true, foreign_key: true

  end
end
