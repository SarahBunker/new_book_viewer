require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
  @first = true
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  redirect "/" unless(1..@contents.size).cover? number

  @chapter = File.read("data/chp#{number}.txt")

  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  erb :chapter
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    result = []
    text.split("\n\n").each_with_index do |paragraph,index|
      result << "<p id='paragraph#{index}'>#{paragraph}</p>"
    end
    result.join
  end

  def bold_search(text)
    text.gsub(@term, "<strong>#{@term}</strong>")
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    txt = File.read("data/chp#{number}.txt")
    yield name, number, txt
  end
end

def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter  do |name, number, text|
    text.split("\n\n").each_with_index do |paragraph, id_num|
      results << {name: name, number: number, id_num: id_num, paragraph: paragraph} if paragraph.include?(query)
    end
  end

  results
end

get "/search" do
  @term = params[:query]
  @results = chapters_matching(params[:query])

  erb :search
end
