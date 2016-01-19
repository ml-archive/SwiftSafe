//
//  Safe.swift
//  Safe
//
//  Created by Honza Dvorsky on 1/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import Foundation

public typealias SafeAccess = () -> ()

/**
 *  Represents the safe-access object. Own it by your thread-safe
 *  class and proxy all synchronizable calls through it.
 */
public protocol Safe {
    
    /**
     *  Blocks calling thread until `access` can safely execute.
     */
    func read(access: SafeAccess)
    
    /**
     *  Returns immediately, `access` executes as soon as is safely possible.
     */
    func write(access: SafeAccess)
}

let QueueName = "com.honzadvorsky.safe.queue"

/**
 *  Exclusive read, exclusive write. Only one thread can read
 *  or write at one time.
*/
public class EREW: Safe {
    
    let queue: dispatch_queue_t
    
    public init(queue: dispatch_queue_t = dispatch_queue_create(QueueName, DISPATCH_QUEUE_SERIAL)) {
        self.queue = queue
    }
    
    public func read(access: SafeAccess) {
        dispatch_sync(self.queue, access)
    }
    
    public func write(access: SafeAccess) {
        dispatch_async(self.queue, access)
    }
}

/**
 *  Concurrent read, exclusive write. Only one thread can write or
 *  multiple threads can read. Write waits for all previously-enqueued
 *  reads to finish, executes, then reads can start again. Barrier-based.
 */
public class CREW: Safe {
    
    let queue: dispatch_queue_t
    
    public init(queue: dispatch_queue_t = dispatch_queue_create(QueueName, DISPATCH_QUEUE_CONCURRENT)) {
        self.queue = queue
    }

    public func read(access: SafeAccess) {
        dispatch_sync(self.queue, access)
    }
    
    public func write(access: SafeAccess) {
        dispatch_barrier_async(self.queue, access)
    }
}
