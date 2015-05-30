require 'httparty'

module SentimentAnalysis
    def calculate_sentiment(text)
        response = HTTParty.get('https://api.idolondemand.com/1/api/sync/analyzesentiment/v1', {query: {text:text, apikey: 'd55419b0-1eec-4957-a93d-aabeb11bf0c2'}})


        response_hash = JSON.parse(response.to_json)

        aggregate_sentiment = response_hash['aggregate']['sentiment']
        aggregate_score =  response_hash['aggregate']['score']
        return {aggregate_sentiment : aggregate_sentiment ,
                aggregate_score : aggregate_score}
    end
end