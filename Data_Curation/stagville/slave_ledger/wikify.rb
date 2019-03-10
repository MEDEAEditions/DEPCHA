#!/usr/bin/env ruby

require 'csv'
require 'pry'

lines = CSV.read('cleaned.csv')

# we want to build pages of wiki_text
pages = []
page_titles = []
page = ""
year = ""
lines.each_with_index do |line,i|
#  binding.pry if pages.size == 10
  # either a row is a page beginning row or it is a content row
  if line[0] =~ /[Pp]age/
#    print "Starting a new page for #{line[0]}\n"
    pages << page
    page_titles << line[0]
    page = ""
  else
    if line[1] =~ /\d\d\d\d/
      year = line[1].strip
    elsif line[1]
      month_day = line[1]
    end

    if line[2] =~ /\b[Dd][Rr]\b/
      account_line = line[2]
      account_holder = nil
      agent = nil

      if account_line.match /(.*)\b[Dd][Rr]\b/
        account_holder = $1
        if account_holder.match /(.*)\b[Pp][Pp]\b(.*)/
          account_holder = $1
          agent = $2
        end
      else
        # can't parse account_holder
        binding.pry
      end

      if account_line =~ /\b[Pp][Pp]\s*(.*)/ && agent.nil?
        agent = $1
        agent.gsub!(/\bpd\b|\bpaid\b/,'')
        if agent =~ /[Ss]elf/
          agent = nil
        end
      end

      account_holder.sub!(/\s*$/,'')
      agent.sub!(/\s*$/,'') if agent
      agent = nil if agent == ""
      account_line.sub!(account_holder, "[[#{account_holder}]]")
      account_line.sub!(agent, "[[#{agent}]]") if agent
      new_account = true

      # Occasionally entries list a name and an amount on this same line
      if line[3] || line[4] || line[5] || line[6]
        pounds = line[3]
        shillings = line[4]
        pence = line[5]      
        notes = line[6]
        balance_line = true
      end      

    else
      new_account = false
      if line[2] =~ /----*/
        hr = true
      else
        hr = false
        skip = false
        if line[2] || line[3] || line[4] || line[5] || line[6]
          transfer = line[2]
          pounds = line[3]
          shillings = line[4]
          pence = line[5]      
          notes = line[6]
        else
          skip = true
        end
      end
    end
#    print "\t#{year}\t#{month_day}\t#{account_holder}\t#{agent}\n" if new_account 

    unless skip
      if new_account
        page << "\n==#{account_line}==\n"
        page << "| !Date | !Commodity | !Pounds | !Shillings | !Pence | !Notes |\n"
        page << "| ----- | ----- | ----- | ----- | ----- | ----- |\n"
        if balance_line
          page << "| #{month_day} |     | #{pounds} | #{shillings} | #{pence} | #{notes} |\n"
        end
      else
        if hr
          page << "\n\n------------------------------\n\n"
        else
          page << "| #{month_day} | #{transfer} | #{pounds} | #{shillings} | #{pence} | #{notes} |\n"
        end
      end
    end
  end   

end
pages << page
# consider popping the first, blank page, or just ignore it when we write the text

pages.each_with_index do |page,i|
  if page_titles[i]
    prefix = "#{i}".rjust(4,'0')
    title = page_titles[i].gsub(/\s/,'_')
    filename = "wiki/#{prefix}_#{title}.txt"
    File.write(filename, page)
  end
end

#binding.pry

p 'foo'
