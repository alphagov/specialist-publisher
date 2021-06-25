module Importers
  module ProtectedFoodDrinkName
    class Parser
      def initialize(data)
        @data = data
      end

      def get_attributes
        {
          title: title,
          registered_name: registered_name,
          register: register,
          status: status,
          class_category: class_category,
          protection_type: protection_type,
          reason_for_protection: reason_for_protection,
          country_of_origin: country,
          traditional_term_grapevine_product_category: traditional_term_grapevine_product_category,
          traditional_term_type: traditional_term_type,
          traditional_term_language: traditional_term_language,
          date_application: date_application,
          date_registration: date_registration,
          time_registration: time_registration,
          date_registration_eu: date_registration_eu,
          body: body,
          summary: summary,
          internal_notes: internal_notes,
        }
      end

    private

      attr_reader :data

      def title
        data["Title"]
      end

      def registered_name
        data["Registered name"]
      end

      def register
        if data["Protection type"] == "American viticultural area" || data["Protection type"] == "US spirit drink"
          return "american-viticultural-areas"
        end

        if data["Protection type"] == "Name protected by international treaty"
          return "names-protected-by-international-treaty"
        end

        case data["Product type"]
        when "Aromatised wine" then "aromatised-wines"
        when "Spirit drink" then "spirit-drinks"
        when "Wine" then "wines"
        when "Traditional term" then "traditional-terms-for-wine"
        when "Food"
          if data["Protection type"] == "Traditional Specialities Guaranteed (TSG)"
            "foods-traditional-speciality-guaranteed"
          else
            "foods-designated-origin-and-geographical-indication"
          end
        end
      end

      def status
        status_map[data["Status"]]
      end

      def class_category
        data_string = data["Class or category of product"]

        return %w[15-vodka 31-flavoured-vodka] if data_string == "15. Vodka, 31. Flavoured vodka"

        [class_category_map[data_string]]
      end

      def protection_type
        protection_type_map[data["Protection type"]]
      end

      def reason_for_protection
        reason_for_protection_map[data["Reason for protection"]]
      end

      def country
        return [] if data["Country of origin"].blank?

        data["Country of origin"].split(", ").map do |country_string|
          country_map[country_string]
        end
      end

      def traditional_term_grapevine_product_category
        return [] if data["Traditional term grapevine product category"].blank?

        data["Traditional term grapevine product category"].split(", ").map do |category_string|
          grapevine_category_map[category_string]
        end
      end

      def traditional_term_type
        term_type_map[data["Traditional term type"]]
      end

      def traditional_term_language
        language_map[data["Traditional term language"]]
      end

      def date_application
        parse_date(data["Date of application"])
      end

      def date_registration
        parse_date(data["Date of UK registration"])
      end

      def time_registration
        "23:00"
      end

      def date_registration_eu
        parse_date(data["Date of original registration with the EU"])
      end

      def summary
        case data["Protection type"]
        when "Geographical indication (GI)"
          case data["Product type"]
          when "Spirit drink"
            "Protected spirit drink name"
          when "Aromatised wine"
            "Protected aromatised wine name"
          end
        when "Protected Geographical Indication (PGI)"
          case data["Product type"]
          when "Food"
            "Protected food name with Protected Geographical Indication (PGI)"
          when "Wine"
            "Protected wine name with Protected Geographical Indication (PGI)"
          end
        when "Protected Designation of Origin (PDO)"
          case data["Product type"]
          when "Food"
            "Protected food name with Protected Designation of Origin (PDO)"
          when "Wine"
            "Protected wine name with Protected Designation of Origin (PDO)"
          end || ""
        when "Traditional Specialities Guaranteed (TSG)"
          "Protected food name with Traditional Speciality Guaranteed (TSG)"
        when "Traditional Term"
          "Traditional term for wine"
        when "Name protected by international treaty"
          "Name protected by international treaty"
        when "American viticultural area"
          "American viticultural area"
        when "US spirit drink"
          "Protected spirit drink name"
        end
      end

      def body
        content = ""

        # Product specification
        if data["Product type"] != "Traditional term" && data["Reason for protection"] != "UK trade agreement"
          content += "## Product specification \n\n" \
            "The product specification is not yet available on this site. " \
            "For any enquiries please [email Defra](mailto:protectedfoodnames@defra.gov.uk).\n\n" \
        end

        # Decision notice and protection instrument title
        if data["Decision notice"].present? && data["Protection instrument"].present?
          content += "\n## Decision notice and protection instrument\n"
        elsif data["Decision notice"].present?
          content += "\n## Decision notice\n"
        elsif data["Protection instrument"].present?
          content += "\n## Protection instrument\n"
        end

        # Decision notice
        if data["Decision notice"].present?
          content += "\n#{data['Decision notice']}\n"
        end

        # Protection instrument
        if data["Protection instrument"].present?
          content += "\n[Protection instrument for #{registered_name}]" \
            "(#{data['Protection instrument']})"

          content += if data["Date of publication of the instrument"].present?
                       ". Date of publication of the instrument: #{data['Date of publication of the instrument']}.\n"
                     else
                       "\n"
                     end
        end

        # Summary
        if data["Summary"].present?
          content += "\n## Summary\n\n#{data['Summary']}\n"
        end

        # Legislation
        if data["Legislation"].present?
          content += "\n## Legislation\n\n#{data['Legislation']}\n"
        end

        # Notes
        if data["Notes"].present?
          content += "\n## Notes\n\n#{data['Notes']}\n"
        end

        content
      end

      def internal_notes
        data["Internal notes"]
      end

      def parse_date(date)
        return if date.blank?

        begin
          Date.strptime(date, "%d/%m/%Y").to_s("%Y-%m-%d")
        rescue ArgumentError
          nil
        end
      end

      def status_map
        @status_map ||= {
          "Registered" => "registered",
          "Applied" => "applied-for",
          "Published" => "in-consultation",
          "Rejected" => "rejected",
        }
      end

      def class_category_map
        @class_category_map ||= {
          "Class 1.1. Fresh meat (and offal)" => "1-1-fresh-meat-and-offal",
          "Class 1.2. Meat products (cooked, salted, smoked, etc.)" => "1-2-meat-products-cooked-salted-smoked-etc",
          "Class 1.3. Cheeses" => "1-3-cheeses",
          "Class 1.4. Other products of animal origin (eggs, honey, various dairy products except butter, etc.)" => "1-4-other-products-of-animal-origin-eggs-honey-various-dairy-products-except-butter-etc",
          "Class 1.5. Oils and fats (butter, margarine, oil, etc.)" => "1-5-oils-and-fats-butter-margarine-oil-etc",
          "Class 1.6. Fruit, vegetables and cereals fresh or processed" => "1-6-fruit-vegetables-and-cereals-fresh-or-processed",
          "Class 1.7. Fresh fish, molluscs, and crustaceans and products derived therefrom" => "1-7-fresh-fish-molluscs-and-crustaceans-and-products-derived-therefrom",
          "Class 1.8. Other products of Annex I of the Treaty (spices etc.)" => "1-8-other-products-of-annex-i-of-the-treaty-spices-etc",
          "Class 2.1. Beers" => "2-1-beers",
          "Class 2.2. Chocolate and derived products" => "2-2-chocolate-and-derived-products",
          "Class 2.3. Bread, pastry, cakes, confectionery, biscuits and other baker's wares" => "2-3-bread-pastry-cakes-confectionery-biscuits-and-other-bakers-wares",
          "Class 2.4. Beverages made from plant extracts" => "2-4-beverages-made-from-plant-extracts",
          "Class 2.5. Pasta" => "2-5-pasta",
          "Class 2.6. Salt" => "2-6-salt",
          "Class 2.7. Natural gums and resins" => "2-7-natural-gums-and-resins",
          "Class 2.8. Mustard paste" => "2-8-mustard-paste",
          "Class 2.9. Hay" => "2-9-hay",
          "Class 2.10. Essential oils" => "2-10-essential-oils",
          "Class 2.11. Cork" => "2-11-cork",
          "Class 2.12. Cochineal (raw product of animal origin)" => "2-12-cochineal-raw-product-of-animal-origin",
          "Class 2.13. Flowers and ornamental plants" => "2-13-flowers-and-ornamental-plants",
          "Class 2.14. Cotton" => "2-14-cotton",
          "Class 2.15. Wool" => "2-15-wool",
          "Class 2.16. Wicker" => "2-16-wicker",
          "Class 2.17. Scutched flax" => "2-17-scutched-flax",
          "Class 2.18. Leather" => "2-18-leather",
          "Class 2.19. Fur" => "2-19-fur",
          "Class 2.20. Feather" => "2-20-feather",
          "Class 2.20a. Rush" => "2-20a-rush",
          "Class 2.21. Prepared meals" => "2-21-prepared-meals",
          "Class 2.22. Beers" => "2-22-beers",
          "Class 2.23. Chocolate and derived products" => "2-23-chocolate-and-derived-products",
          "Class 2.24. Bread, pastry, cakes, confectionery, biscuits and other baker's wares" => "2-24-bread-pastry-cakes-confectionery-biscuits-and-other-bakers-wares",
          "Class 2.25. Beverages made from plant extracts" => "2-25-beverages-made-from-plant-extracts",
          "Class 2.26. Pasta" => "2-26-pasta",
          "Class 2.27. Salt" => "2-27-salt",
          "Wine" => "wine",
          "1. Rum" => "1-rum",
          "2. Whisky or Whiskey" => "2-whisky-or-whiskey",
          "3. Grain spirit" => "3-grain-spirit",
          "4. Wine spirit" => "4-wine-spirit",
          "5. Brandy or Weinbrand" => "5-brandy-or-weinbrand",
          "6. Grape marc spirit or grape marc" => "6-grape-marc-spirit-or-grape-marc",
          "7. Fruit marc spirit" => "7-fruit-marc-spirit",
          "8. Raisin spirit or raisin brandy" => "8-raisin-spirit-or-raisin-brandy",
          "9. Fruit spirit" => "9-fruit-spirit",
          "10. Cider spirit and perry spirit" => "10-cider-spirit-and-perry-spirit",
          "11. Honey spirit" => "11-honey-spirit",
          "12. Hefebrand or lees spirit" => "12-hefebrand-or-lees-spirit",
          "13. Bierbrand or eau de vie de bière" => "13-bierbrand-or-eau-de-vie-de-biere",
          "14. Topinambur or Jerusalem artichoke spirit" => "14-topinambur-or-jerusalem-artichoke-spirit",
          "15. Vodka" => "15-vodka",
          "16. Spirit (preceded by the name of the fruit) obtained by maceration and distillation" => "16-spirit-preceded-by-the-name-of-the-fruit-obtained-by-maceration-and-distillation",
          "17. Geist (with the name of the fruit or the raw material used)" => "17-geist-with-the-name-of-the-fruit-or-the-raw-material-used",
          "18. Gentian" => "18-gentian",
          "19. Juniper-flavoured spirit drinks" => "19-juniper-flavoured-spirit-drinks",
          "20. Gin" => "20-gin",
          "21. Distilled gin" => "21-distilled-gin",
          "22. London gin" => "22-london-gin",
          "23. Caraway-flavoured spirit drinks" => "23-caraway-flavoured-spirit-drinks",
          "24. Akvavit or aquavit" => "24-akvavit-or-aquavit",
          "25. Aniseed-flavoured spirit drinks" => "25-aniseed-flavoured-spirit-drinks",
          "26. Pastis" => "26-pastis",
          "27. Pastis de Marseille" => "27-pastis-de-marseille",
          "28. Anis" => "28-anis",
          "29. Distilled anis" => "29-distilled-anis",
          "30. Bitter-tasting spirit drinks or bitter" => "30-bitter-tasting-spirit-drinks-or-bitter",
          "31. Flavoured vodka" => "31-flavoured-vodka",
          "32. Liqueur" => "32-liqueur",
          "33. Crème de (followed by the name of a fruit or the raw material used)" => "33-creme-de-followed-by-the-name-of-a-fruit-or-the-raw-material-used",
          "34. Crème de cassis" => "34-creme-de-cassis",
          "35. Guignolet" => "35-guignolet",
          "36. Punch au rhum" => "36-punch-au-rhum",
          "37. Sloe gin" => "37-sloe-gin",
          "37a. Sloe-aromatised spirit drink or Pacharán" => "37a-sloe-aromatised-spirit-drink-or-pacharan",
          "38. Sambuca" => "38-sambuca",
          "39. Maraschino, Marrasquino or Maraskino" => "39-maraschino-marrasquino-or-maraskino",
          "40. Nocino" => "40-nocino",
          "41. Egg liqueur or advocaat or avocat or advokat" => "41-egg-liqueur-or-advocaat-or-avocat-or-advokat",
          "42. Liqueur with egg" => "42-liqueur-with-egg",
          "43. Mistrà" => "43-mistra",
          "44. Väkevä glögi or spritglögg" => "44-vakeva-glogi-or-spritglogg",
          "45. Berenburg or Beerenburg" => "45-berenburg-or-beerenburg",
          "46. Honey or mead nectar" => "46-honey-or-mead-nectar",
          "47. Other spirit drinks" => "47-other-spirit-drinks",
          "99. Other spirit drink" => "99-other-spirit-drink",
          "1. Aromatised wine" => "1-aromatised-wine",
          "2. Aromatised wine-based drink" => "2-aromatised-wine-based-drink",
          "Traditional term" => "traditional-term",
          "Spirit drink" => "spirit-drink",
          "No class or category" => "no-class-category",
        }
      end

      def protection_type_map
        @protection_type_map ||= {
          "Protected Geographical Indication (PGI)" => "protected-geographical-indication-pgi",
          "Protected Designation of Origin (PDO)" => "protected-designation-of-origin-pdo",
          "Traditional Specialities Guaranteed (TSG)" => "traditional-speciality-guaranteed-tsg",
          "Traditional Term" => "traditional-term",
          "Geographical indication (GI)" => "geographical-indication-gi",
          "Name protected by international treaty" => "name-protected-by-international-treaty",
          "American viticultural area" => "american-viticultural-area",
          "US spirit drink" => "us-spirit-drink",
        }
      end

      def country_map
        @country_map ||= {
          "United Kingdom" => "united-kingdom",
          "Andorra" => "andorra",
          "Armenia" => "armenia",
          "Australia" => "australia",
          "Austria" => "austria",
          "Belgium" => "belgium",
          "Brazil" => "brazil",
          "Bulgaria" => "bulgaria",
          "Cambodia" => "cambodia",
          "Chile" => "chile",
          "China" => "china",
          "Colombia" => "colombia",
          "Costa Rica" => "costa-rica",
          "Croatia" => "croatia",
          "Cyprus" => "cyprus",
          "Czechia" => "czechia",
          "Denmark" => "denmark",
          "Dominican Republic" => "dominican-republic",
          "El Salvador" => "el-salvador",
          "Ecuador" => "ecuador",
          "Estonia" => "estonia",
          "Finland" => "finland",
          "France" => "france",
          "Georgia" => "georgia",
          "Germany" => "germany",
          "Greece" => "greece",
          "Guatemala" => "guatemala",
          "Guinea" => "guinea",
          "Guyana" => "guyana",
          "Honduras" => "honduras",
          "Hungary" => "hungary",
          "India" => "india",
          "Indonesia" => "indonesia",
          "Ireland" => "ireland",
          "Italy" => "italy",
          "Japan" => "japan",
          "Latvia" => "latvia",
          "Liechtenstein" => "liechtenstein",
          "Lithuania" => "lithuania",
          "Luxembourg" => "luxembourg",
          "Malta" => "malta",
          "Mexico" => "mexico",
          "Moldova" => "moldova",
          "Mongolia" => "mongolia",
          "Morocco" => "morocco",
          "Netherlands" => "netherlands",
          "Norway" => "norway",
          "Panama" => "panama",
          "Peru" => "peru",
          "Poland" => "poland",
          "Portugal" => "portugal",
          "Romania" => "romania",
          "Russia" => "russia",
          "Serbia" => "serbia",
          "Slovakia" => "slovakia",
          "Slovenia" => "slovenia",
          "South Africa" => "south-africa",
          "South Korea" => "south-korea",
          "Spain" => "spain",
          "Sri Lanka" => "sri-lanka",
          "Sweden" => "sweden",
          "Switzerland" => "switzerland",
          "Thailand" => "thailand",
          "Trinidad and Tobago" => "trinidad-and-tobago",
          "Turkey" => "turkey",
          "Ukraine" => "ukraine",
          "United States" => "united-states",
          "Vietnam" => "vietnam",
        }
      end

      def grapevine_category_map
        @grapevine_category_map ||= {
          "Wine" => "wine",
          "New wine still in fermentation" => "new-wine-still-in-fermentation",
          "Liqueur wine" => "liqueur-wine",
          "Sparkling wine" => "sparkling-wine",
          "Quality sparkling wine" => "quality-sparkling-wine",
          "Quality aromatic sparkling wine" => "quality-aromatic-sparkling-wine",
          "Aerated sparkling wine" => "aerated-sparkling-wine",
          "Semi-sparkling wine" => "semi-sparkling-wine",
          "Aerated semi-sparkling wine" => "aerated-semi-sparkling-wine",
          "Grape must" => "grape-must",
          "Partially fermented grape must" => "partially-fermented-grape-must",
          "Partially fermented grape must extracted from raisined grapes" => "partially-fermented-grape-must-extracted-from-raisined-grapes",
          "Concentrated grape must" => "concentrated-grape-must",
          "Rectified concentrated grape must" => "rectified-concentrated-grape-must",
          "Wine from raisined grapes" => "wine-from-raisined-grapes",
          "Wine of overripe grapes" => "wine-of-overripe-grapes",
          "Wine vinegar" => "wine-vinegar",
        }
      end

      def term_type_map
        @term_type_map ||= {
          "Description of product characteristic" => "description-of-product-characteristic",
          "In place of PDO/PGI" => "in-place-of-pdo-pgi",
        }
      end

      def language_map
        @language_map ||= {
          "Bulgarian" => "bulgarian",
          "Croatian" => "croatian",
          "Czech" => "czech",
          "Danish" => "danish",
          "Dutch" => "dutch",
          "English" => "english",
          "Estonian" => "estonian",
          "Finnish" => "finnish",
          "French" => "french",
          "German" => "german",
          "Greek" => "greek",
          "Hungarian" => "hungarian",
          "Irish" => "irish",
          "Italian" => "italian",
          "Latin" => "latin",
          "Latvian" => "latvian",
          "Lithuanian" => "lithuanian",
          "Maltese" => "maltese",
          "Polish" => "polish",
          "Portuguese" => "portuguese",
          "Romanian" => "romanian",
          "Slovak" => "slovak",
          "Slovenian" => "slovenian",
          "Spanish" => "spanish",
          "Swedish" => "swedish",
        }
      end

      def reason_for_protection_map
        @reason_for_protection_map ||= {
          "UK geographical indication from before 2021" => "uk-gi-before-2021",
          "EU agreement" => "eu-agreement",
          "UK trade agreement" => "uk-trade-agreement",
          "Application to UK scheme from 2021" => "uk-gi-after-2021",
        }
      end
    end
  end
end
