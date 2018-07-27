# resque-brain: a better resque-web

**This app is no longer maintained**

* If you would like to take ownership of this app, please reach out to us.
* We still use this app internally, but it's too difficult to maintain as open source while also making it work with our internal
deployment tools.

----

resque-brain is a web app to monitor and manage multiple [Resque][resque] instances.  It is superior to resque-web in three important ways:

[resque]: https://github.com/resque/resque

* it can monitor any number of resque instances, instead of just one (see [the wiki](https://github.com/stitchfix/resque-brain/wiki/Why-Run-Multiple-Resques%3F) for why you'd want to do that).
* it allows for "retry & clear" on failed jobs, to re-queue the job and remove it from the failed queue in one step
* it has a responsive design, thus working on mobile browsers

## Other Features

- Include rake tasks to monitor the health of your resque instances
- UI focused on issues, not just dumping the contents of the queues:
  - stale workers
  - large queues
  - failed jobs
- View [resque-scheduler][scheduler] schedule and manually queue jobs

[scheduler]: https://github.com/resque/resque-scheduler

## Planned Features

- Visibility into delayed and retry queues, if using 
- Extensibility

# UI

## Summary of all monitored Resques

The home page gives you a summary of all resques you have configured

![Summary](https://www.evernote.com/shard/s71/sh/9760b70b-90b7-4abe-a8e7-79f2d3d221e6/01947177c452e155e3d4a6afcedcf2c1/deep/0/Resque-Brain.png)

## Overview of the Resque instance

Drilling into a single Resque, you get quick overview of what's going on, namely how many jobs are working, waiting, and failed.

![Overview](https://www.evernote.com/shard/s71/sh/d5fee356-e87c-4710-bd95-d683ae74cc23/c992f3d442d3e1af26f204c05a362a34/deep/0/Resque-Brain.png)

## Jobs currently running

This shows only which jobs are actually running, and when they started.  Jobs running "too long" are called out.

![Jobs Running](https://www.evernote.com/shard/s71/sh/42ecf2e0-55d1-416b-90c2-a9f6be8d1d6d/3894cb722ca6000bc1c4b5d7162b4a69/deep/0/Resque-Brain.png)

## Jobs waiting

This shows all the queues and how many jobs are in each one.  Any queue with a nonzero number of jobs is highlighted so you can
hone in on exactly what you care about.

![Jobs Waiting](https://www.evernote.com/shard/s71/sh/61780dea-2f4b-46ec-b525-a49accdba405/50ff5184d3f1b30bdbf07aec6067cb8d/deep/0/Resque-Brain.png)

## Failed queue

We see a more readable summary of what's going on, along with direct links to search google for the problem.  We also have the ability to retry and clear at the same time.  So many newcomers to Resque think that retry does a clear, and are baffled when the job "fails again" (i.e. stays in the failed queue).

![Failed Queue](https://www.evernote.com/shard/s71/sh/ad202253-9cff-4933-8025-e608e1964b32/795b279b021cf55ef08ca3ea89c37f89/deep/0/Resque-Brain.png)

We can expand to see exceptions

![Exception View](https://www.evernote.com/shard/s71/sh/c367b25b-dc5c-4cec-889d-b13af7e61858/13002418848f32f088a4dcdd889e4f03/deep/0/Resque-Brain.png)

## Schedule

![Scheduler](https://cloud.githubusercontent.com/assets/22282/6201079/3158ab44-b464-11e4-870f-c97b07309b46.png)

## Mobile View

The design is completely responsive, meaning you can tend to your queues while on the go.

![Mobile View](https://www.evernote.com/shard/s71/sh/554347f4-bcae-4c77-aa36-3e2db28b2008/6fbb410e5aabc619e520a3b4e62d34c2/deep/0/Resque-Brain.png)

# Running

See [Set Up](https://github.com/stitchfix/resque-brain/wiki/Set-Up) on the wiki.

## Local Development

You'll need to do three things:

* Install `Bower` (which requires npm, which requires node)
* Install PhantomJS
* Set up your environment:

  Easiest thing is to create a `.env.development` file by running:

  ```
  > bin/setup
  ```

  Then:

  ```
  > foreman start
  ```

  The app will be running on http://localhost:5000

To run tests:

```
> rake test # run server-side tests
> rake teaspoon # run JavaScript tests
```

# Rake Tasks for Monitoring

See [the Set Up page](https://github.com/stitchfix/resque-brain/wiki/Set-Up) on the wiki, as well as [Monitoring & Alerting](https://github.com/stitchfix/resque-brain/wiki/Monitoring-and-Alerting) for a discussion of how its set up.

# Limitations

* This only works with the default Redis-based Failure backend.  It *does* work with resque-retry because resque-retry defers to
that backend.  [I don't believe you should use the other back-ends](https://github.com/stitchfix/resque-brain/wiki/Why-you-shouldn't-use-other-Resque-Falure-Back-ends).
* Just as with resque-web, if multiple people are manipulating the failed queue at the same time bad things will happen.  This is
a function of the poor design of the failed queue implementation.  Be warned.
* The Web UI is not extensible, so currently this is no visibility into resque-scheduler or resque-retry.

