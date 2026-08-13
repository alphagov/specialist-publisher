namespace :rfc_192 do
  desc "Updates known non-RFC-192-compliant base paths"
  task fix: :environment do
    non_compliant_documents.each do |non_compliant_document|
      document = Document.find(non_compliant_document[:content_id], "en")
      old_base_path = document.base_path

      if old_base_path == non_compliant_document[:old_base_path]
        puts "Renaming #{non_compliant_document[:content_id]}:"
        puts "         #{non_compliant_document[:old_base_path]} to #{non_compliant_document[:new_base_path]}"
        document.base_path = non_compliant_document[:new_base_path]
        document.update_type = "minor"
        if document.save
          document.publish
        end
        puts("Failed: #{document.errors.full_messages.join(', ')}") if document.errors.any?
      elsif old_base_path == non_compliant_document[:new_base_path]
        puts "Skipping #{non_compliant_document[:content_id]} because already fixed"
      else
        puts "Skipping #{non_compliant_document[:content_id]} because old base path doesn't match"
      end
    end
  end
end

def non_compliant_documents
  [
    {
      content_id: "9e52c615-8762-49da-b4d6-d245ad9015b8",
      old_base_path: "/residential-property-tribunal-decisions/flat-2-4-union-road-new-mills-high-peak-derbyshire-sk22-3es-bir_17uh_mnr_2018_0062",
      new_base_path: "/residential-property-tribunal-decisions/flat-2-4-union-road-new-mills-high-peak-derbyshire-sk22-3es-bir-17uh-mnr-2018-0062",
    },
    {
      content_id: "7b229fad-cef5-428a-bf26-ad5b46e80346",
      old_base_path: "/research-for-development-outputs/induction-of-cell-death-after-localization-to-the-host-cell-mitochondria-by-the-mycobacterium-tuberculosis-pe_pgrs33-protein",
      new_base_path: "/research-for-development-outputs/induction-of-cell-death-after-localization-to-the-host-cell-mitochondria-by-the-mycobacterium-tuberculosis-pe-pgrs33-protein",
    },
    {
      content_id: "ac20b278-27c4-4d5e-88ad-b209cc669bd6",
      old_base_path: "/research-for-development-outputs/diversity-of-human-immunodeficiency-virus-type-1-subtype-a-and-crf03_ab-protease-in-eastern-europe-selection-of-the-v77i-variant-and-its-rapid-spread-in-injecting-drug-user-populations",
      new_base_path: "/research-for-development-outputs/diversity-of-human-immunodeficiency-virus-type-1-subtype-a-and-crf03-ab-protease-in-eastern-europe-selection-of-the-v77i-variant-and-its-rapid-spread-in-injecting-drug-user-populations",
    },
    {
      content_id: "7e4f096a-a4cd-4c85-89e4-d7ba7cfb9bb8",
      old_base_path: "/residential-property-tribunal-decisions/5-greenacres-park-coppits-hill-yeovil-somerset-ba21-2pp_chi-40ud-phi-2019-0205",
      new_base_path: "/residential-property-tribunal-decisions/5-greenacres-park-coppits-hill-yeovil-somerset-ba21-2pp-chi-40ud-phi-2019-0205",
    },
    {
      content_id: "6207404d-2a6e-46bd-bdc8-05109411ec39",
      old_base_path: "/administrative-appeals-tribunal-decisions/warwick-district-council-v-secretary-of-state-for-work-and-pensions-and-ch-hb-2020-ukut-240-aac_",
      new_base_path: "/administrative-appeals-tribunal-decisions/warwick-district-council-v-secretary-of-state-for-work-and-pensions-and-ch-hb-2020-ukut-240-aac",
    },
    {
      content_id: "3a141410-8e2f-428c-acd2-917fe51ad58c",
      old_base_path: "/european-structural-investment-funds/research-and-innovation-call-in-sheffield-city-region_-oc28r18p-0837",
      new_base_path: "/european-structural-investment-funds/research-and-innovation-call-in-sheffield-city-region-oc28r19p-0936",
    },
    {
      content_id: "9a07aeeb-591e-45f4-a7d1-7d6f50ef001a",
      old_base_path: "/employment-tribunal-decisions/ms-g-adeji-v-miss-ca$h-sportswear-london-3200533-slash-2023",
      new_base_path: "/employment-tribunal-decisions/ms-g-adeji-v-miss-cash-sportswear-london-3200533-slash-2023",
    },
  ]
end
