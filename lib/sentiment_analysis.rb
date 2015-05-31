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
