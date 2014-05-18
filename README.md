# resque-brain: a better resque-web

![build status](https://travis-ci.org/davetron5000/resque-brain.svg?branch=master)

resque-brain is a web app to monitor and manage multiple [Resque][resque] instances.  It is superior to resque-web in three
important ways:

[resque]: https://github.com/resque/resque

* it can monitor any number of resque instances, instead of just one
* it allows for "retry & clear" on failed jobs, to re-queue the job and remove it from the failed queue in one step
* it has a responsive design, thus working on mobile browsers

## Planned Features

- ability to kill workers
- Monitoring/Alerting
- Statistics collection
- Visibility for resque-scheduler, if installed
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

## Mobile View

The design is completely responsive, meaning you can tend to your queues while on the go.

![Mobile View](https://www.evernote.com/shard/s71/sh/554347f4-bcae-4c77-aa36-3e2db28b2008/6fbb410e5aabc619e520a3b4e62d34c2/deep/0/Resque-Brain.png)

# Running

To use resque-brain, arrange to have it deployed as you do with other Rails apps.  You will need to configure two things in the
environment - Resque instances to monitor, and login credentials.

## Resque Instances

* Set `RESQUE_BRAIN_INSTANCES` to a comma-delimited list of Resque instance names.  They can be anything, but url-friendly labels
are recommended.  
* For each instance name set `RESQUE_BRAIN_INSTANCES_thename` to the redis url to your Resque's redis

```
RESQUE_BRAIN_INSTANCES=www,admin,api
RESQUE_BRAIN_INSTANCES_www=redis://09809sfasdf@myredis.com:8765
RESQUE_BRAIN_INSTANCES_admin=redis://9ryfkfg@myredis.com:8766
RESQUE_BRAIN_INSTANCES_api=redis://77f77ff@myredis.com:8767
```

## Authentication

Currently, only HTTP Auth is available.  Allow access by setting these in the environment:

* `HTTP_AUTH_USERNAME` - username
* `HTTP_AUTH_PASSWORD` - password

## Local Development

You'll need to do three things:

* Install `Bower` (which requires npm, which requires node)
* Install PhantomJS
* Set up your environment:

  Easiest thing is to create a `.env` like so:

  ```
  RESQUE_BRAIN_INSTANCES=localhost
  RESQUE_BRAIN_INSTANCES_localhost=redis://localhost:6379
  HTTP_AUTH_USERNAME=a
  HTTP_AUTH_PASSWORD=a
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

# Limitations

* This only works with the default Redis-based Failure backend.  It *does* work with resque-retry because resque-retry defers to
that backend.  Personally, I don't believe you should use the other back-ends, so supporting the multi-queue backend, for
example, is not high on my priority list
* Just as with resque-web, if multiple people are manipulating the failed queue at the same time bad things will happen.  This is
a function of the poor design of the failed queue implementation.  Be warned.
* The Web UI is not extensible, so currently this is no visibility into resque-scheduler or resque-retry.

