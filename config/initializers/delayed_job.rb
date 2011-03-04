Delayed::Worker.destroy_failed_jobs = false

class Delayed::Worker
  alias_method :original_handle_failed_job, :handle_failed_job

  def handle_failed_job(job, error)
    HoptoadNotifier.notify(error)
    original_handle_failed_job(job, error)
  end
end