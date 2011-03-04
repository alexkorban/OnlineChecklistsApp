class DelayedMailer < Struct.new(:method, :args)
  def self.push(method, *args)
    Delayed::Job.enqueue(DelayedMailer.new(method, *args))
  end

  def perform
    raise "Test exception in signup email"
    Mailer.send(method, *args).deliver
  end

  def failure(job, exception)
    HoptoadNotifier.notify(exception)
  end
end