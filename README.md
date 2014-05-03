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

## Summary of all monitored Resques

![Summary](https://www.evernote.com/shard/s71/sh/d22d92df-e4e4-42a0-910e-d54ee5b80c30/1c59f8c50613f8d513495e03f019ef00/deep/0/Cursor-and-ResqueBrain-and-nav.coffee-(--Projects-resque-brain-app-assets-javascripts)---VIM1.png)

## Overview of the Resque instance

Just shows what you care about, namely have jobs failed and are any workers potentitally stuck.

![Overview](https://www.evernote.com/shard/s71/sh/393c9f46-8d55-42c3-bb40-ef8c3a1799cb/d40d83e1793239fc4e0df9edf793805f/deep/0/ResqueBrain.png)

## Jobs currently running

Again, we don't see a  bunch of queues with zeros next to them, instead we see just what's running, as well as any job that's been running for "too long"

![Jobs Running](https://www.evernote.com/shard/s71/sh/cc02a3a2-be7e-4c7e-a6bb-97cb2e8984b1/5da89167a60f706160ef6279404b17db/deep/0/ResqueBrain-and-README.md-(--Projects-resque-brain)---VIM1.png)

### Killing a worker

We can kill a worker through the UI without going into console.  Workers get stuck, and sometimes need killing.

![Killing Worker](https://www.evernote.com/shard/s71/sh/890e9060-ed2f-4a9c-ac87-6c26adeb2cd6/3344b1cca6ac698b70376ac98fa56373/deep/0/ResqueBrain.png)

## Jobs waiting

Here we see what's queued up.  Again, we don't see a bunch of zeros—just what's waiting to be processed.  We can also see if there are "too many" jobs of a certain type queued up.

![Jobs Waiting](https://www.evernote.com/shard/s71/sh/af317bd1-1008-49a7-896e-dbb7ed3e268a/dbe3572974b948cf35ba85abccd3f8ba/deep/0/ResqueBrain.png)

## Failed queue

We see a more readable summary of what's going on, along with direct links to search google for the problem.  We also have the ability to retry and clear at the same time.  So many newcomers to Resque think that retry does a clear, and are baffled when the job "fails again" (i.e. stays in the failed queue).

![Failed Queue](https://www.evernote.com/shard/s71/sh/392fa832-d624-4555-b0bf-234a938fb502/3a8d37b12e7e350e75289bf3859a2d75/deep/0/ResqueBrain.png)

We can expand to see exceptions

![Exception View](https://www.evernote.com/shard/s71/sh/db773b9f-863d-4e63-9f42-f4fe0044b6e0/5b05e134319b90e5921b619de34d01db/deep/0/ResqueBrain.png)

### Mobile View

*And* it doesn't look like crap on mobile.  So, you can tend to your queueus on the go with one hand.

![Mobile View](https://www.evernote.com/shard/s71/sh/83a464b0-ed1a-410d-9929-da39e7dcca75/5867da4b8a4ff3087c718e8ed45d74bf/deep/0/ResqueBrain.png)

# API

The app is an AngularJS app, so the back-end needs an API:

## Resques `/resques`

```json
[
  { 
    name: "www"
  },
  { 
    name: "admin"
  }
]
```

## Overview `/resques/:resque`

```json
{
  failed: 5,
  running: {
    total: 24,
    tooLong: 3
  }
  waiting: 145
}
```

## Running `/resques/:resque/jobs/running`

```json
[
  { 
    queue: "mail",
    job: {
      name: "WelcomeMailer",
      started: 398454809843,
      payload: [ 1234, 5688 ],
    },
    worker: "as2048tgeorjgnsdfg",
  },
  // ...
]
```

## Kill worker `/resques/:resque/workers/:worker

DELETE

## Waiting `/resques/:resque/jobs/waiting`

[
  {
    queue: "mail",
    numJobs: 45
  },
]

## Failed `/resques/:resque/jobs/failed?start=0&pageSize=10`

[
  {
    // resque failed queue payload
  },
]

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
