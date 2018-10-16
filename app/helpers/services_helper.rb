module ServicesHelper
  def getuserAvaliability(user)
    Booking.getAvaliabilities(user)
  end

  def getuserBooking(user)
    Booking.getBookings(user)
  end

  def getLocations
    ['Jersey City','Broklyn','Manhattan','Bronx']
  end

  def get_checked_value_location(location)
    location.blank? ? false : true
   end

  def getReviewAverageRating(user)

    reviews=Review.where(:stylist_id => user.id)

    if !reviews.blank?

     average=reviews.average(:average_rating)
     return average.blank? ? 0 : average.round
    else
      return 0
    end

  end


  def getServiceName(user,service_id)
    all_services=[]

    services=user.services.where(['is_deleted = ? AND id <> ?',false, service_id])
    services.each do |service|
        service_name= {"id": service.id, "service_name": service.service_sub_category.name, "service_time": service.time, "service_amount": service.amount}
      all_services.push(service_name)
    end

    return all_services.to_json
  end

  def getDescription
    ['Golden hairs','massage with olive oil','bridal look','nail styling']

  end



  def getLocationsize(service)
    count=0

    if !service.location1.blank?

      count +=1
    end
      if !service.location2.blank?
        count +=1

      end
      if !service.location3.blank?
        count +=1

      end
      if !service.location4.blank?
        count +=1

      end
      if !service.location5.blank?
        count +=1

      end

    return count
  end

  def get_service_sub_cat_by_first_service_cat
    return ServiceCategory.all.first.service_sub_categories
  end

  def get_cities_of_new_york
   return ["Accord", "Adams", "Adams Center", "Addison", "Akron", "Albany", "Albertson", "Albion", "Alden", "Alexander", "Alexandria Bay", "Alfred", "Alfred Station", "Allegany", "Almond", "Alplaus", "Altamont", "Altmar", "Amagansett", "Amawalk", "Amenia", "Amityville", "Amsterdam", "Andes", "Andover", "Angelica", "Angola", "Annandale-on-Hudson", "Apalachin", "Appleton", "Aquebogue", "Arcade", "Ardsley", "Argyle", "Arkville", "Armonk", "Arverne", "Ashville", "Astoria", "Athens", "Athol", "Atlanta", "Atlantic Beach", "Attica", "Au Sable Forks", "Auburn", "Aurora", "Austerlitz", "Ava", "Averill Park", "Avon", "Babylon", "Bainbridge", "Baldwin", "Baldwin Place", "Baldwinsville", "Ballston Lake", "Ballston Spa", "Barryville", "Barton", "Batavia", "Bath", "Bay Shore", "Bayport", "Bayside", "Bayville", "Beacon", "Bearsville", "Bedford", "Bedford Hills", "Bellerose", "Belleville", "Bellmore", "Bellport", "Belmont", "Bemus Point", "Bergen", "Berkshire", "Berne", "Bethpage", "Big Flats", "Binghamton", "Black River", "Blauvelt", "Bliss", "Blodgett Mills", "Bloomingburg", "Bloomingdale", "Blossvale", "Blue Mountain Lake", "Blue Point", "Bohemia", "Boiceville", "Bolivar", "Bolton Landing", "Boonville", "Boston", "Bovina Center", "Brant Lake", "Brantingham", "Brasher Falls", "Breezy Point", "Brentwood", "Brewerton", "Brewster", "Briarcliff Manor", "Bridgehampton", "Bridgeport", "Bridgewater", "Brier Hill", "Brightwaters", "Broadalbin", "Brockport", "Brocton", "Bronxville", "Brookfield", "Brookhaven", "Brooklyn", "Brooktondale", "Brushton", "Buchanan", "Buffalo", "Bullville", "Burdett", "Burlington Flats", "Burnt Hills", "Burt", "Buskirk", "Byron", "Cadyville", "Cairo", "Caledonia", "Callicoon", "Calverton", "Cambria Heights", "Cambridge", "Camden", "Cameron", "Cameron Mills", "Camillus", "Campbell", "Campbell Hall", "Canaan", "Canajoharie", "Canandaigua", "Canastota", "Candor", "Canisteo", "Canton", "Cape Vincent", "Carle Place", "Carmel", "Caroga Lake", "Carthage", "Cassadaga", "Castile", "Castle Point", "Castleton-on-Hudson", "Castorland", "Cato", "Catskill", "Cattaraugus", "Cayuta", "Cazenovia", "Cedarhurst", "Celoron", "Center Moriches", "Centereach", "Centerport", "Central Bridge", "Central Islip", "Central Square", "Central Valley", "Chaffee", "Champlain", "Chappaqua", "Charlotteville", "Chatham", "Chaumont", "Chautauqua", "Chazy", "Chemung", "Chenango Forks", "Cherry Valley", "Chester", "Chestertown", "Chittenango", "Churchville", "Cicero", "Cincinnatus", "Clarence", "Clarence", "Clark Mills", "Claryville", "Claverack", "Clay", "Clayton", "Cleveland", "Clifton Park", "Clifton Springs", "Climax", "Clinton", "Clinton Corners", "Clintondale", "Clyde", "Clymer", "Cobleskill", "Cochecton", "Coeymans", "Coeymans Hollow", "Cohocton", "Cohoes", "Cold Brook", "Cold Spring", "Cold Spring Harbor", "Colden", "College Point", "Collins", "Commack", "Comstock", "Conesus", "Congers", "Conklin", "Constableville", "Constantia", "Coopers Plains", "Cooperstown", "Copake", "Copake Falls", "Copenhagen", "Copiague", "Coram", "Corfu", "Corinth", "Corning", "Cornwall-on-Hudson", "Cornwallville", "Corona", "Cortland", "Cottekill", "Cowlesville", "Coxsackie", "Craryville", "Croghan", "Crompond", "Cropseyville", "Cross River", "Croton Falls", "Croton-on-Hudson", "Crown Point", "Cuba", "Cuddebackville", "Cutchogue", "Dale", "Dalton", "Dannemora", "Dansville", "Darien Center", "De Kalb Junction", "DeRuyter", "Deansboro", "Deer Park", "Delanson", "Delevan", "Delhi", "Delmar", "Denver", "Depew", "Deposit", "Derby", "Dexter", "Diamond Point", "Dickinson Center", "Dobbs Ferry", "Dodgewood", "Dolgeville", "Dover Plains", "Downsville", "Dryden", "Duanesburg", "Dundee", "Dunkirk", "Durhamville", "Eagle Bridge", "Earlton", "Earlville", "East Amherst", "East Aurora", "East Berne", "East Branch", "East Chatham", "East Durham", "East Elmhurst", "East Greenbush", "East Hampton", "East Islip", "East Marion", "East Meadow", "East Meredith", "East Moriches", "East Northport", "East Norwich", "East Pharsalia", "East Quogue", "East Rochester", "East Rockaway", "East Setauket", "East Syracuse", "Eastchester", "Eastport", "Eaton", "Eden", "Edmeston", "Edwards", "Elba", "Elbridge", "Eldred", "Elizabethtown", "Ellenburg Center", "Ellenburg Depot", "Ellenville", "Ellicottville", "Elma", "Elmhurst", "Elmira", "Elmont", "Elmsford", "Endicott", "Erieville", "Erin", "Esperance", "Etna", "Evans Mills", "Fabius", "Fairport", "Falconer", "Fallsburg", "Far Rockaway", "Farmingdale", "Farmington", "Farmingville", "Fayetteville", "Ferndale", "Feura Bush", "Fillmore", "Fishers Island", "Fishkill", "Fleischmanns", "Floral Park", "Florida", "Flushing", "Fly Creek", "Fonda", "Forest Hills", "Forestport", "Forestville", "Fort Ann", "Fort Drum", "Fort Edward", "Fort Montgomery", "Fort Plain", "Frankfort", "Franklin", "Franklin Square", "Franklinville", "Fredonia", "Freehold", "Freeport", "Freeville", "Fresh Meadows", "Frewsburg", "Fulton", "Fultonham", "Fultonville", "Gainesville", "Galway", "Gansevoort", "Garden City", "Gardiner", "Garnerville", "Garrison", "Gasport", "Geneseo", "Geneva", "Genoa", "Georgetown", "Germantown", "Gerry", "Getzville", "Ghent", "Gilbertsville", "Gilboa", "Glasco", "Glen Cove", "Glen Head", "Glen Oaks", "Glen Spey", "Glenfield", "Glenmont", "Glens Falls", "Glenwood Landing", "Gloversville", "Goldens Bridge", "Goshen", "Gouverneur", "Gowanda", "Grand Island", "Granville", "Great Neck", "Great River", "Greene", "Greenlawn", "Greenport", "Greenvale", "Greenville", "Greenwich", "Greenwood", "Greenwood Lake", "Groton", "Guilderland", "Guilford", "Hadley", "Hall", "Hamburg", "Hamilton", "Hamlin", "Hammond", "Hammondsport", "Hampton Bays", "Hancock", "Hannacroix", "Hannibal", "Harford", "Harpursville", "Harriman", "Harrison", "Harrisville", "Hartsdale", "Hartwick", "Hastings", "Hastings-on-Hudson", "Hauppauge", "Haverstraw", "Hawthorne", "Hemlock", "Hempstead", "Henrietta", "Herkimer", "Hermon", "Heuvelton", "Hewlett", "Hicksville", "High Falls", "Highland", "Highland Falls", "Highland Mills", "Hillburn", "Hillsdale", "Hilton", "Himrod", "Hogansburg", "Holbrook", "Holland", "Holland Patent", "Holley", "Hollis", "Holmes", "Holtsville", "Homer", "Honeoye", "Honeoye Falls", "Hoosick", "Hoosick Falls", "Hopewell Junction", "Hornell", "Horseheads", "Houghton", "Howard Beach", "Howes Cave", "Hubbardsville", "Hudson", "Hudson Falls", "Hunt", "Huntington", "Huntington Station", "Hurley", "Hurleyville", "Hyde Park", "Ilion", "Indian Lake", "Interlaken", "Inwood", "Ionia", "Irving", "Irvington", "Island Park", "Islandia", "Islip", "Islip Terrace", "Ithaca", "Jackson Heights", "Jamaica", "Jamesport", "Jamestown", "Jamesville", "Jasper", "Jay", "Jefferson", "Jefferson Valley", "Jericho", "Johnson", "Johnson City", "Johnsonville", "Johnstown", "Jordan", "Katonah", "Kauneonga Lake", "Keene", "Keene Valley", "Keeseville", "Kennedy", "Kent", "Kerhonkson", "Keuka Park", "Kew Gardens", "Kiamesha Lake", "Kinderhook", "Kings Park", "Kingston", "Kirkville", "Kirkwood", "LaFayette", "Lacona", "Lagrangeville", "Lake George", "Lake Grove", "Lake Katrine", "Lake Luzerne", "Lake Peekskill", "Lake Placid", "Lake Pleasant", "Lake View", "Lakeville", "Lakewood", "Lancaster", "Lansing", "Larchmont", "Latham", "Laurens", "Lawrence", "Le Roy", "Lee Center", "Leeds", "Leicester", "Leonardsville", "Levittown", "Lewis", "Lewiston", "Liberty", "Lily Dale", "Lima", "Limestone", "Lincolndale", "Lindenhurst", "Lindley", "Linwood", "Lisbon", "Lisle", "Little Falls", "Little Neck", "Little Valley", "Liverpool", "Livingston Manor", "Livonia", "Loch Sheldrake", "Locke", "Lockport", "Lockwood", "Locust Valley", "Lodi", "Long Beach", "Long Island City", "Long Lake", "Lorraine", "Lowville", "Lynbrook", "Lyndonville", "Lyons", "Macedon", "Machias", "Madison", "Madrid", "Mahopac", "Malone", "Malverne", "Mamaroneck", "Manhasset", "Manlius", "Mannsville", "Manorville", "Marathon", "Marcellus", "Marcy", "Margaretville", "Marietta", "Marion", "Marlboro", "Martville", "Maryland", "Masonville", "Maspeth", "Massapequa", "Massapequa Park", "Massena", "Mastic", "Mastic Beach", "Mattituck", "Maybrook", "Mayfield", "Mayville", "McDonough", "McGraw", "Mechanicville", "Medford", "Medina", "Mellenville", "Melville", "Memphis", "Mendon", "Meridian", "Merrick", "Mexico", "Middle Granville", "Middle Grove", "Middle Island", "Middle Village", "Middleburgh", "Middleport", "Middlesex", "Middletown", "Milford", "Mill Neck", "Millbrook", "Miller Place", "Millerton", "Millwood", "Milton", "Mineola", "Mineville", "Minoa", "Modena", "Mohawk", "Mohegan Lake", "Monroe", "Monsey", "Montauk", "Montezuma", "Montgomery", "Monticello", "Montour Falls", "Montrose", "Mooers", "Mooers Forks", "Moravia", "Moriah", "Moriches", "Morris", "Morrisonville", "Morristown", "Morrisville", "Mount Kisco", "Mount Morris", "Mount Sinai", "Mount Tremper", "Mount Upton", "Mount Vernon", "Mount Vision", "Mountainville", "Munnsville", "Nanuet", "Naples", "Narrowsburg", "Nassau", "Natural Bridge", "Nedrow", "Nesconset", "Neversink", "New Berlin", "New City", "New Hampton", "New Hartford", "New Hyde Park", "New Lebanon", "New Paltz", "New Rochelle", "New Windsor", "New Woodstock", "New York", "New York Mills", "Newark", "Newark Valley", "Newburgh", "Newcomb", "Newfane", "Newfield", "Newport", "Niagara Falls", "Nicholville", "Nineveh", "North Babylon", "North Bangor", "North Branch", "North Brookfield", "North Chili", "North Collins", "North Creek", "North Greece", "North Rose", "North Salem", "North Tonawanda", "Northport", "Northrup's of West Bloomfield Mobile Home Park", "Northville", "Norwich", "Norwood", "Nunda", "Nyack", "Oakdale", "Oakfield", "Oakland Gardens", "Oceanside", "Odessa", "Ogdensburg", "Old Bethpage", "Old Chatham", "Old Forge", "Old Westbury", "Olean", "Olivebridge", "Olmstedville", "Oneida", "Oneonta", "Ontario", "Orangeburg", "Orchard Park", "Orient", "Oriskany", "Oriskany Falls", "Ossining", "Oswego", "Otego", "Otisville", "Otto", "Ovid", "Owego", "Oxford", "Oyster Bay", "Ozone Park", "Painted Post", "Palisades", "Palmyra", "Panama", "Parish", "Patchogue", "Patterson", "Pattersonville", "Paul Smiths", "Pavilion", "Pawling", "Pearl River", "Peconic", "Peekskill", "Pelham", "Penfield", "Penn Yan", "Pennellville", "Perry", "Peru", "Phelps", "Philadelphia", "Phoenicia", "Phoenix", "Piermont", "Piffard", "Pine Bush", "Pine City", "Pine Hill", "Pine Island", "Pine Plains", "Piseco", "Pitcher", "Pittsford", "Plainview", "Plattekill", "Plattsburgh", "Pleasant Valley", "Pleasantville", "Plymouth", "Poestenkill", "Point Lookout", "Poland", "Pomona", "Pompey", "Port Byron", "Port Chester", "Port Crane", "Port Henry", "Port Jefferson", "Port Jefferson Station", "Port Jervis", "Port Leyden", "Port Washington", "Porter Corners", "Portland", "Portville", "Potsdam", "Pottersville", "Poughkeepsie", "Poughquag", "Pound Ridge", "Prattsburgh", "Preble", "Preston Hollow", "Pulaski", "Purchase", "Purdys", "Purling", "Putnam Station", "Putnam Valley", "Queens Village", "Queensbury", "Quogue", "Randolph", "Ransomville", "Raquette Lake", "Ravena", "Red Creek", "Red Hook", "Redfield", "Redwood", "Rego Park", "Remsen", "Remsenburg", "Rensselaer", "Rensselaer Falls", "Rexford", "Rexville", "Rhinebeck", "Richfield Springs", "Richford", "Richland", "Richmond Hill", "Richmondville", "Ridge", "Ripley", "Riverhead", "Rochester", "Rock Hill", "Rock Tavern", "Rockaway Park", "Rockville Centre", "Rocky Point", "Rodman", "Rome", "Romulus", "Ronkonkoma", "Roosevelt", "Roscoe", "Rosedale", "Rosendale", "Roslyn", "Roslyn Heights", "Rotterdam Junction", "Round Top", "Rouses Point", "Roxbury", "Rush", "Rushford", "Rushville", "Russell", "Rye", "Sackets Harbor", "Sag Harbor", "Sagaponack", "Saint Albans", "Saint Bonaventure", "Saint James", "Saint Johnsville", "Saint Regis Falls", "Salamanca", "Salem", "Salisbury Mills", "Salt Point", "Sanborn", "Sand Lake", "Sandy Creek", "Saranac Lake", "Saratoga Springs", "Saugerties", "Sauquoit", "Savannah", "Sayville", "Scarsdale", "Schaghticoke", "Schenectady", "Schenevus", "Schodack Landing", "Schoharie", "Schroon Lake", "Schuylerville", "Scipio Center", "Scottsburg", "Scottsville", "Sea Cliff", "Seaford", "Selden", "Selkirk", "Seneca Falls", "Shandaken", "Sharon Springs", "Shelter Island", "Shelter Island Heights", "Sherburne", "Sherrill", "Shirley", "Shokan", "Shoreham", "Shrub Oak", "Sidney", "Sidney Center", "Silver Bay", "Silver Creek", "Silver Lake", "Silver Springs", "Sinclairville", "Skaneateles", "Skaneateles Falls", "Slate Hill", "Slingerlands", "Sloansville", "Sloatsburg", "Smithtown", "Smithville Flats", "Smyrna", "Sodus", "Somers", "Sound Beach", "South Cairo", "South Fallsburg", "South Glens Falls", "South Jamesport", "South New Berlin", "South Otselic", "South Ozone Park", "South Plymouth", "South Salem", "South Wales", "Southampton", "Southfields", "Southold", "Sparkill", "Sparrow Bush", "Speculator", "Spencer", "Spencerport", "Spencertown", "Sprakers", "Spring Glen", "Spring Valley", "Springfield Gardens", "Springville", "Springwater", "Staatsburg", "Stamford", "Stanfordville", "Stanley", "Star Lake", "Staten Island", "Steamburg", "Stephentown", "Sterling Forest", "Stillwater", "Stone Ridge", "Stony Brook", "Stony Creek", "Stony Point", "Stormville", "Stratford", "Stuyvesant", "Suffern", "Sugar Loaf", "Sunnyside", "Sylvan Beach", "Syosset", "Syracuse", "Tappan", "Tarrytown", "The Bronx", "Thendara", "Thiells", "Thornwood", "Three Mile Bay", "Ticonderoga", "Tillson", "Tivoli", "Tomkins Cove", "Tonawanda", "Treadwell", "Tribes Hill", "Troupsburg", "Trout Creek", "Troy", "Trumansburg", "Truxton", "Tuckahoe", "Tully", "Tupper Lake", "Turin", "Tuxedo Park", "Ulster Park", "Unadilla", "Union Springs", "Uniondale", "Unionville", "Upper Jay", "Upton", "Utica", "Vails Gate", "Valatie", "Valhalla", "Valley Cottage", "Valley Falls", "Valley Stream", "Van Etten", "Verbank", "Vernon Center", "Verona", "Verplanck", "Vestal", "Victor", "Voorheesville", "Waccabuc", "Wading River", "Wainscott", "Walden", "Walker Valley", "Wallkill", "Walton", "Walworth", "Wampsville", "Wanakena", "Wantagh", "Wappingers Falls", "Warners", "Warnerville", "Warrensburg", "Warsaw", "Warwick", "Washingtonville", "Wassaic", "Water Mill", "Waterford", "Waterloo", "Waterport", "Watertown", "Waterville", "Watervliet", "Watkins Glen", "Waverly", "Wayland", "Webster", "Weedsport", "Wells", "Wellsville", "West Babylon", "West Chazy", "West Cornwall", "West Coxsackie", "West Edmeston", "West Falls", "West Haverstraw", "West Hempstead", "West Henrietta", "West Islip", "West Leyden", "West Monroe", "West Nyack", "West Park", "West Point", "West Sand Lake", "West Sayville", "West Shokan", "West Stockholm", "West Valley", "West Winfield", "Westbrookville", "Westbury", "Westerlo", "Westernville", "Westfield", "Westford", "Westhampton", "Westhampton Beach", "Westmoreland", "Westport", "Westtown", "White Plains", "Whitehall", "Whitesboro", "Whitestone", "Whitesville", "Whitney Point", "Willet", "Williamson", "Williamstown", "Williston Park", "Willsboro", "Willseyville", "Wilson", "Windham", "Windsor", "Wingdale", "Winthrop", "Wolcott", "Woodbourne", "Woodbury", "Woodgate", "Woodhaven", "Woodhull", "Woodmere", "Woodridge", "Woodside", "Woodstock", "Wurtsboro", "Wyandanch", "Wynantskill", "Wyoming", "Yaphank", "Yonkers", "York", "Yorkshire", "Yorktown Heights", "Yorkville", "Youngstown", "Yulan"]
  end

  def getstylistService(user)

    return user.services.map(&:service_category).to_json

  end

  def getServiceCat(user)
    service_category=[]
    services=user.services
    return services.map(&:service_categories).uniq

  end


  def getAmount
    ['40','60','80','100','120','150','175','200']
  end
end
