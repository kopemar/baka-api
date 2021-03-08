class ApplicationService

  def initialize(*args)
    super()
  end
  
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
