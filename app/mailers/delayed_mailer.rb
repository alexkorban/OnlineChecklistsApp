class DelayedMailer < Struct.new(:method, :args)
  def self.push(method, *args)
    Delayed::Job.enqueue(DelayedMailer.new(method, *args))
  end

  def perform
    Mailer.send(method, *args).deliver
  end

#  def failure(job, exception)
#    HoptoadNotifier.notify(exception)
#  end
end