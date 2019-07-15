require 'net/http'
require 'json'

$defaultURL = "https://api.noopschallenge.com"

def getURL(url)
    return JSON.parse(Net::HTTP.get URI("#{$defaultURL}#{url}"))
end

def getQuestion(url)
    question = getURL(url)
    if question["exampleResponse"]!=nil
        exampleAnswer = "\n\e[34mExample Answer: \e[0m" + question["exampleResponse"]["answer"]
    else
        exampleAnswer = ""
    end
    puts "\e[36mQuestion: \e[0m" + question["message"] + exampleAnswer
    question.each do |object|
        if object[0] != "message" and object[0] != "exampleResponse"
            puts "\e[33mAdditional Info:\e[0m #{object[0]}"
            puts "#{object}"
        end
    end
    answer = gets.chomp
    postAnswer(answer, url)
end

def postAnswer(answer, url)
    pack = Net::HTTP.post URI("#{$defaultURL}#{url}"), { "answer" => answer }.to_json, "Content-Type" => "application/json"
    res = JSON.parse(pack.body)

    if res["result"] === "correct"
        puts res["message"] + " \e[32mPress Enter to continue.\e[0m"
        gets
        getQuestion(res["nextQuestion"])
    elsif res["result"] === "interview complete"
        puts "\e[32m#{res["message"]}\nGrade:\e[0m #{res["grade"]}\n\e[32mElapsed Seconds:\e[0m #{res["elapsedSeconds"]}"
        return
    else
        puts "\e[31m#{res["message"]}\e[0m"
        getQuestion(url)
    end
end

start = getURL("/fizzbot")
puts start["message"] + "\n\e[35mPress Enter to start.\e[0m"
gets
getQuestion(start["nextQuestion"])