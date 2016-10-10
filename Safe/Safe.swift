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
    func read(_ access: SafeAccess)
    
    /**
     *  Returns immediately, `access` executes as soon as is safely possible.
     */
    func write(_ access: @escaping SafeAccess)
}

let QueueName = "com.honzadvorsky.safe.queue"

/**
 *  Exclusive read, exclusive write. Only one thread can read
 *  or write at one time.
*/
open class EREW: Safe {
    
    let queue: DispatchQueue
    
    public init(queue: DispatchQueue = DispatchQueue(label: QueueName, attributes: [])) {
        self.queue = queue
    }
    
    open func read(_ access: SafeAccess) {
        self.queue.sync(execute: access)
    }
    
    open func write(_ access: @escaping SafeAccess) {
        self.queue.async(execute: access)
    }
}

/**
 *  Concurrent read, exclusive write. Only one thread can write or
 *  multiple threads can read. Write waits for all previously-enqueued
 *  reads to finish, executes, then reads can start again. Barrier-based.
 */
open class CREW: Safe {
    
    let queue: DispatchQueue
    
    public init(queue: DispatchQueue = DispatchQueue(label: QueueName, attributes: DispatchQueue.Attributes.concurrent)) {
        self.queue = queue
    }

    open func read(_ access: SafeAccess) {
        self.queue.sync(execute: access)
    }
    
    open func write(_ access: @escaping SafeAccess) {
        self.queue.async(flags: .barrier, execute: access)
    }
}
