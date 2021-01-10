#########################################################
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.0.0"
    }
    http = {
      source = "hashicorp/http"
      version = ">= 2.0.0"
    }
  }
  required_version = ">= 0.13.4"
}

########################################################
variable "mycity" {
    type = string
    default = "gothenburg"
    description = "where you live"
}

#########################################################
data "http" "location" {
  # url = "https://www.metaweather.com/api/location/search/?lattlong=57.701328,11.96689"
    url = "https://www.metaweather.com/api/location/search/?query=${var.mycity}"
    request_headers = {
        "Accept" = "application/json"
    }
}

locals {
   locationwoeid = "https://www.metaweather.com/api/location/${jsondecode(data.http.location.body)[0]["woeid"]}"
}

/* Debug info
 output "CityInformation" {
    value = data.null_data_source.locationwoeid.outputs
 }
*/


data "http" "weather" {
    url = local.locationwoeid
    request_headers = {
        "Accept" = "application/json"
    }
}

###########################################################
output "TodayForecast" {
    value = {
	"City" = jsondecode(data.http.weather.body)["title"]
	"lowest" = floor(jsondecode(data.http.weather.body)["consolidated_weather"][0]["min_temp"])
	"highest" = ceil(jsondecode(data.http.weather.body)["consolidated_weather"][0]["max_temp"])
    }
}
