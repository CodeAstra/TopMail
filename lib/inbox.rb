UPPER_LIMIT_ON_EMAILS_COUNT = 200

require 'contextio'

class Inbox
  def initialize(user)
    @user = user
    # @user = OpenStruct.new
    # @user.email = "chi6rag@codeastra.com"
    @threads = []
    @messages = []
    contextio = ContextIO.new(CONTEXTIO_KEYS[@user.email][:key], CONTEXTIO_KEYS[@user.email][:secret])
    @account = contextio.accounts.where(email: @user.email).first
    # @messages_dump = @account.messages.where(include_body: 1).where(limit: UPPER_LIMIT_ON_EMAILS_COUNT)
    @messages_dump = @account.messages.where(limit: UPPER_LIMIT_ON_EMAILS_COUNT)
  end

  # def populate_mesages!
  #   @messages_dump.each do |message_dump|
  #     thread = MessageThread.find_or_create_by(gmail_thread_id: message_dump.gmail_thread_id)
  #     thread.messages.find_or_create_by(gmail_message_id: message_dump.gmail_message_id) do |msg|
  #       msg.subject = message_dump.subject
  #     end
  #   end
  # end

  def sort
    @messages_dump.each do |message_dump|
      message = get_message_from_dump(message_dump)
      add_message_to_thread(message)
    end

    update_thread_meta_data!
    normalize_thread_scores!
    sort_threads!

    return @threads
  end

private
  def get_message_from_dump(message_dump)
    message = {}
    message[:from] = message_dump.addresses["from"]
    message[:from]["thumbnail"] = message_dump.person_info[message[:from]["email"]]["thumbnail"]
    # message[:to] = message_dump.addresses["to"]
    # i = 0
    # message[:to].each do |recepient|
    #   message[:to][i][recepient["email"]]["thumbnail"] = message_dump.person_info[recepient["email"]]["thumbnail"]
    #   i +=1
    # end
    message[:gmail_message_id] = message_dump.gmail_message_id
    message[:gmail_thread_id] = message_dump.gmail_thread_id
    # message[:attachments_count] = message_dump.files.count
    message[:time] = message_dump.date
    message[:subject] = message_dump.subject
    # message[:body] = message_dump.body[0]["content"].gsub("\r", " ").gsub("\n", " ")

    @messages.push(message)

    return message
  end

  def add_message_to_thread(message)
    thread = @threads.select{|th| th[:gmail_thread_id] == message[:gmail_thread_id]}.first
    thread_was_nil = thread.nil?
    thread = empty_thread(message[:gmail_thread_id]) if thread_was_nil
    thread[:messages].push(message)
    thread[:sentiment_score] += message_sentiment_score(message)
    # thread.length_of_messages += message[:body].length
    thread[:keywords_score] += message_keyword_score(message[:subject])
    @threads.push(thread) if thread_was_nil
    return thread
  end

  def empty_thread(gmail_thread_id)
    {
      gmail_thread_id: gmail_thread_id,
      sentiment_score: 0,
      time_since_last_reply: 0,
      streak_of_unreplied_messages: 0,
      # length_of_messages: 0,
      keywords_score: 0,
      messages: []
    }
  end

  def update_thread_meta_data!
    @threads.each do |thread|
      update_time_since_last_reply_of_thread!(thread)
      update_streak_of_unreplied_messages_of_thread!(thread)
    end
  end

  def update_time_since_last_reply_of_thread!(thread)
    time_now = Time.now.to_i
    time_since_last_reply = 0
    thread[:messages].each do |message|
      break if message_was_from_user(message, @user)
      time_since_last_reply += (time_now - message[:time])
    end
    thread[:time_since_last_reply] = time_since_last_reply
  end

  def update_streak_of_unreplied_messages_of_thread!(thread)
    streak_of_unreplied_messages = 0
    thread[:messages].each do |message|
      break if message_was_from_user(message, @user)
      streak_of_unreplied_messages += 1
    end
    thread[:streak_of_unreplied_messages] = streak_of_unreplied_messages
  end

  def normalize_thread_scores!(param = nil)
    if param.nil?
      [
        :sentiment_score,
        :time_since_last_reply,
        :streak_of_unreplied_messages,
        # :length_of_messages,
        :keywords_score
        ].each do |param|
          normalize_thread_scores!(param)
        end
      else
        min = 999999
        max = -999999
        @threads.each do |thread|
          min = (min > thread[param]) ? thread[param] : min
          max = (max < thread[param]) ? thread[param] : max
        end

        if min != max
          @threads.each do |thread|
            thread[param] = 10.0*(thread[param] - min)/(max - min)
          end
        end
      end
    end

    def sort_threads!
      @threads.sort!{|t1, t2| total_thread_score(t2) <=> total_thread_score(t1)}  
    end

    def total_thread_score(thread)
      weights = {
        sentiment_score: -4,
        time_since_last_reply: 1,
        streak_of_unreplied_messages: 4,
        # length_of_messages: 2,
        keywords_score: 1,
      }

      weights.keys.collect {|wt| thread[wt]*weights[wt]}.reduce(&:+)
    end

    def message_sentiment_score(message)
    # TODO: Fix this
    return rand(10)
  end

  def message_keyword_score(txt)
    # TODO: Fix this
    score = rand(10)
    txt = txt.downcase
    %W[happy good nice satified awesome god heaven pleasan smooth amaz great].each do |word|
      score -= 2*(txt.scan(word).count)
    end
    %W[suck irritat frustat screw kill die dead late pathet worst irrita dirt hell].each do |word|
      score += 2*(txt.scan(word).count)
    end
    return score
  end

  def message_was_from_user(message, user)
    message[:from][:email] == user[:email]
  end
end