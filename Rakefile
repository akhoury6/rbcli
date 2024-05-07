# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :docserver do
  Dir.chdir "docs-src"
  # sh "hugo server --destination public"
  sh "hugo server --renderToMemory"
end

task :docs do
  make_header = Proc.new do |title, weight = 100|
    <<~HEADER
      ---
      title: "#{title}"
      date: #{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S")}-00:00
      draft: false
      weight: #{weight}
      ---
    HEADER
  end

  merge_docs = Proc.new do |header, doc, src, &src_transform|
    doc_text = File.read(doc)
    src_text = File.read(src)
    title_delim_indices = []
    begin_index = nil
    end_index = nil
    doc_text.lines.each_with_index do |line, index|
      title_delim_indices << index if line.chomp =~ /^---$/
      begin_index = index if line.chomp == '<!-- BEGIN -->'
      end_index = index if line.chomp == '<!-- END -->'
    end
    title_delim_index = title_delim_indices[1]
    parts = Array.new
    parts << header
    if begin_index.nil?
      parts << doc_text.lines[(title_delim_index + 1)..-1]
    else
      parts << doc_text.lines[(title_delim_index + 1)..begin_index]
      parts << (src_transform.nil? ? src_text : src_transform.call(src_text))
      parts << "\n" unless (parts.last.is_a?(String) && parts.last.end_with?("\n")) || (parts.last.is_a?(Array) && parts.last.last.end_with?("\n"))
      parts << doc_text.lines[end_index..-1].join unless end_index.nil?
    end
    parts.flatten.join
  end

  changes_exist = Proc.new do |doc1, doc2|
    title_delim_indices = []
    doc1.lines.each_with_index { |line, index| title_delim_indices << index if line.chomp =~ /^---$/ }
    d1_index = title_delim_indices[1]
    title_delim_indices = []
    doc2.lines.each_with_index { |line, index| title_delim_indices << index if line.chomp =~ /^---$/ }
    d2_index = title_delim_indices[1]
    doc1.lines[d1_index..-1] != doc2.lines[d2_index..-1]
  end

  ## Docs Site
  contrib_docfile = 'docs-src/content/development/contributing.md'
  contrib = merge_docs.call(make_header.call('Contribution Guide', 10), contrib_docfile, 'CONTRIBUTING.md')
  File.write(contrib_docfile, contrib) if changes_exist.call(contrib, File.read(contrib_docfile))

  license_docfile = 'docs-src/content/development/license.md'
  license = merge_docs.call(make_header.call('License Info', 20), license_docfile, 'LICENSE.md') do |src_text|
    src_text.gsub(/^# /, '### ')
  end
  File.write(license_docfile, license) if changes_exist.call(license, File.read(license_docfile))

  coc_docfile = 'docs-src/content/development/code_of_conduct.md'
  code_of_conduct = merge_docs.call(make_header.call('Code of Conduct', 30), coc_docfile, 'CODE_OF_CONDUCT.md') do |src_text|
    src_text.gsub(/^# /, '#### ')
  end
  File.write(coc_docfile, code_of_conduct) if changes_exist.call(code_of_conduct, File.read(coc_docfile))

  changelog_docfile = 'docs-src/content/development/changelog.md'
  changelog = merge_docs.call(make_header.call('Changelog', 40), changelog_docfile, 'CHANGELOG.md')
  File.write(changelog_docfile, changelog) if changes_exist.call(changelog, File.read(changelog_docfile))

  version_shortcode_file = 'docs-src/layouts/shortcodes/rbcli_version_minor.html'
  shortcode_version = File.read(version_shortcode_file)
  current_version = Rbcli::VERSION
  File.write(version_shortcode_file, current_version.split('.')[0..1].join('.')) unless shortcode_version.split('.')[0..1] == current_version.split('.')[0..1]

  ## Compressed strings in tool
  require_relative 'lib/rbcli/util/string_compression'
  # Rbcli.log.info "eJy1lE9v2kAQxe/9FE/KJZEIVGlPaVTVQZCgUkDGKOK42GN7lfWuu7vG8rfv\n2ICoEtqmEpnT+s/+dt6b2bm4OHd8uEAb4f1QSVxfI0BqRUG1sc9IjUVCW1Km\nlDpDbIpC6ARKaoIoSyVj4aXRDlIjrDZNR8IBOTRlY2WWe1wOr3Dz8eYzAp1Y\nqvE9N5Xd//2mOCDPGAdklEuH0pqMVYOXqSWCM6mvhaVbNKZCLDQsJdJ5KzeV\nJ0gP9mHA7hQmkWnzAsmfK52Qhc8JnmzhYNLu4WG2wgNpskJhUW3YQExlTNqx\nn5xF+8bllGDzEtluHreZLfeZYWz4jM7+Hkjyd4stWcfP+HQ4bs/ugTN9JfxS\n+FadhSlbyhVLaqCEP4L6/+vlGeNP5TlWIWm7rlWZm5JtzlkOG19LpbAhVI7S\nSvVOIXkznibR43wVIZit8RSEYTCL1l94s+fO9OCW36FlwU3OJ7HjVmjftMae\nQv4YhcNHZgT3k+kkWrd+jyfRbLRcYjwP+U4tgjCaDFfTIMRiFS7myxGbuyTq\nTjmJ/EurpF3jcQ8k5IVU7l91esfyrPl6OPZMJcjFlviaxCS37JjgaVE2b+j7\nV0ihDM+athS89Vh8FjlJoY3vwbFvd7n3pbsdDOq67me66hubDdSO6QZf++8t\nfMw1+FmR280/S5mwSTsjdynwqodSkWCBsdFexDwxnrup902xP30epb8jzx6/\nAF6sdLc=\n".decompress, 'TOOL' ### LICENSE.txt
  lictxt = File.read('LICENSE.txt')
  tool_txt = File.read('exe/rbcli')
  tool_txt = tool_txt.lines.map do |line|
    if line.chomp.end_with?('### LICENSE.txt')
      line.sub(/"[^"]+"/, lictxt.compress.inspect)
    else
      line
    end
  end.join
  File.write('exe/rbcli', tool_txt)

  Dir.chdir "docs-src"
  sh "hugo"
end