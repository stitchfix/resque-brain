# resque-brain: a better resque-web

resque-web, which comes with Resque has a few problems:

- the UI is not helpful
  - what deserves my attention in Resque right now?
  - how do I deal with a failed job?
  - replaying a failed job is counterintuitive
  - not responsive/mobile-friendly
  - cannot kill stuck workers
- It can only show information about one Resque
  - sophisticated platforms have several Resques, but want centralized monitoring
- No actual monitoring
  - how many failed jobs is "too many"?
  - how long is a worker allowed to run before it's "stuck"?
  - how many unprocessed jobs is "too many"?

resque-brain changes that.  resque-brain is useful if:

- you want monitoring of potential or real problems
- your jobs are important, and failures indicate a problem or bug
- you have more than one resque in operation
- you may need this information away from a desktop computer and large monitor

## This biggest underlying problem

Resque's design is hard-coded to force each Ruby VM to have exactly one Resque.  No Ruby VM can access more than one Resque by
just using Resque's API, because Resque shares its connection to redis as a global variable, and it's used by all parts of
Resque.

Enter `Resque::DataStore`.

This class encapsulates *all* Redis access by Resque.  Users of the class will not need to know the keys or data structures that
Resque uses inside Redis.  More importantly, this class can be given any instance of `Redis`, so that multiple instances can
exist in the same VM to access data about different Resques.

# UI

![Overview](https://www.evernote.com/shard/s71/sh/851c6360-ff1e-4da0-b6e2-b912cb516ac7/cd1563e1c0ce730be61a63e69c3cf9c7/deep/0/Re squeBrain.png)

![Jobs Running](https://www.evernote.com/shard/s71/sh/1c63c8b8-e4bc-484d-9711-bc19bcf618a4/d54b2c2b7ee60a24f7dfae3effb5089f/deep/0/ResqueBrain.png)

![Jobs Waiting](https://www.evernote.com/shard/s71/sh/af317bd1-1008-49a7-896e-dbb7ed3e268a/dbe3572974b948cf35ba85abccd3f8ba/deep/0/ResqueBrain.png)

![Failed Queue](https://www.evernote.com/shard/s71/sh/12da7bcf-82f3-49db-b846-f58787e85fc7/c49c5f965cc7ad4996101d29dfea329e/res/9c4b60dd-12c5-4f59-b626-0334c57080f0/skitch.png)


# Notes


What do we want out of resque monitoring?

- Monitor multiple instances
- Automated notifications
  - conditions
    - too many failed jobs
    - queues have too many jobs unprocessed
    - workers in progress for too long
  - channels
    - email
    - web hook
    - status page
  - stats
    - size of queues
    - job processing time (if possible)
- visual overview
  - failed jobs
  - jobs running/workers working
  - jobs waiting
- remediate problems
  - retry jobs
  - kill jobs
  - kill workers

# Overview

* Jobs failed - `num_failed`
* Jobs running -  `worker_ids.map(&:get_worker_payload).compact`
* Too long - introspect Worker.working
* Jobs waiting - Resque.queues.each &:peek

# In Progress

* Worker.working.each
  - queue = Worker#job[:queue]
  - job class = Worker#job[:payload]
  - job args = Worker#job[:payload]
  - runtime = Worker#job[:run_at]
  - kill worker - Worker#unregister_worker

# Waiting

Resque>queues + peek

# Failed

- failed jobs - Resque::Failure
- link to source - with configured git repo, could use convention.
- google search - simple link
- retry, clear, retry & clear - see resque-web, but must be safer than what that app does
- email - simple mailer or even copy&paste link


# Accessing multiple resques

* We can't use pretty  much any code in Redsque as it stands
- Ideally, we'd have an interface that represents all Redis operations that Resque uses, and that interface
  would take a redis connection in the constructor.
