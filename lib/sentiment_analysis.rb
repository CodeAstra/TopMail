require 'httparty'

module SentimentAnalysis
  def self.calculate(text)
    response = HTTParty.get(
      'https://api.idolondemand.com/1/api/sync/analyzesentiment/v1',
      {
        query: {
          text:text,
          apikey: ENV['SENTIMENT_ANALYSIS_API_KEY']
        }
      }
    )

    response_hash = JSON.parse(response.to_json)

    aggregate_score =  response_hash['aggregate']['score']
    return aggregate_score
  end
end

# require 'httparty'

# module SentimentAnalysis

#   texts = [
#     "I am a pathetic person",
#     "Today is going to be a good day",
#     "I wish you were dead"
#   ]

#   def self.calculate(texts)
#     actions = []
#     for text in texts
#       actions.push(
#         {
#           name:"analyzesentiment",
#           version:"v1",
#           params:{
#             text:text
#           }
#         }
#       )
#     end
#     job_id = HTTParty.post(
#       'https://api.idolondemand.com/1/job',
      
#         {
#           actions: actions,
#           apikey: "ae974106-b56e-425a-8de6-9290ec2ec4c8"
#         }
      
#     )

#     puts job_id.response.inspect

#     result = HTTParty.get(
#       'https://api.idolondemand.com/1/job/result/' + job_id,
#       {
#         query: {
#           apikey: ENV['SENTIMENT_ANALYSIS_API_KEY'],
#         }
#       }
#     )

#     puts result.inspect
#   end
# end