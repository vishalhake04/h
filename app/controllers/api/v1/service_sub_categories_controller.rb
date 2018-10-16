class Api::V1::ServiceSubCategoriesController < Api::V1::BaseController

  def get_sub_categories_by_service_category
    begin
      sub_services=[]
      service_category=ServiceCategory.find(params[:id])
      sub_services_id=service_category.services.map(&:service_sub_category_id).uniq

      services=sub_services_id.map{|sub_service_id| Service.find_by_service_sub_category_id(sub_service_id)}
      services.each{|service|sub_services.push(Api::V1::ServiceSubCategorySerializer.new(service.service_sub_category,root:false,scope:{amount:service.amount,time:service.time}))}

      render(json:{sub_services:sub_services}.to_json)
    rescue ActiveRecord::RecordNotFound
      not_found_for_services
    end

  end
  
  def not_found_for_services
    render(json: {sub_services:{status: 404, errors: 'Not found'}}.to_json)

  end
  def getServiceSubCatListJson(sub_services)

    render(
        json:sub_services,
              each_serializer: Api::V1::ServiceSubCategorySerializer,scope:{amount:service.amount,time:service.time})

  end


  end
