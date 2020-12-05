Dir[Rails.root.join('db/seeds/*.rb')].each do |f|
  require f
end
