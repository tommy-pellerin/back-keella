# README

## fin our backend link here : https://back-keella.fly.dev/

## How to use User and Workout model :
- to get all workouts reserved by user : user.participated_workouts
- to get all reservations of a user : user.reservations
- to get all workouts posted by host : user.hosted_workouts
- to get the host of the workout : workout.host
- to get all participant of a workout : workout.participants

## here are reservation possible status :
enum :status, {
    pending: 0,
    accepted: 1,
    refused: 2,
    host_cancelled: 3,
    user_cancelled: 4,
    closed: 5,
    relaunched: 6
  }
