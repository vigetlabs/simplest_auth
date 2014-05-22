# simplest_auth Appraisals

%w(3.0 3.1 3.2 4.0 4.1).each do |version|
  appraise "activerecord-#{version}" do
    gem "activerecord", version
  end
end

%w(1.0 1.1 1.2).each do |version|
  appraise "datamapper-#{version}" do
    gem "datamapper", version
  end
end

%w(0.13 0.12 0.11 0.10).each do |version|
  appraise "mongo_mapper-#{version}" do
    gem "mongo_mapper", version
  end
end
