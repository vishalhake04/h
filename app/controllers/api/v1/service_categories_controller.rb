class Api::V1::ServiceCategoriesController < Api::V1::BaseController
  def index
    service_categories=ServiceCategory.all
    getServiceCatListJson(service_categories)


  end


  def get_sub_categories_by_service_category
    @sub_services= ServiceSubCategory.where(:service_category_id=>params[:id])
    getServiceCatJson(@sub_services)

  end

  def getServiceCatJson(sub_services)
    render(json: Api::V1::ServiceCategorySerializer.new(sub_services).to_json)
  end

  def getServiceCatListJson(service_categories)
 
    render(
        json:
                  service_categories,
              each_serializer: Api::V1::ServiceCategorySerializer

    )

  end
end
