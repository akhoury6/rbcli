# Distributed Locking and State Sharing

Distributed Locking allows a [Remote State][state_storage] to be shared among multiple users of the application to make writes appear atomic between sessions. To use it, simply set the  `locking:` parameter to `true` when enabling remote state.

This is how locking works:

1. The application attempts to acquire a lock on the remote state when you first access it
2. If the backend is locked by a different application, wait and try again
3. If it succeeds, the lock is held and refreshed periodically
4. When the application exits, the lock is released
5. If the application does not refresh its lock, or fails to release it when it exits, the lock will automatically expire within 60 seconds
6. If another application steals the lock (unlikely but possible), and the application tries to save data, a `StandardError` will be thrown
7. You can manually attempt to lock/unlock by calling `Rbcli.remote_state.lock` or `Rbcli.remote_state.unlock`, respectively. 


## Manual Locking

Remember: all state in Rbcli is lazy-loaded. Therefore, RBCli wll only attempt to lock the data when you first try to access it. If you need to make sure that the data is locked before executing a block of code, use:

```ruby
Rbcli.remote_state.refresh
```

to force the lock and retrieve the latest data. You can force an unlock by calling:

```ruby
Rbcli.remote_state.disconnect
```

Even if you do not want to store any data, you can leverage manual locking to control access to a different shared resource, such as a stateful API. For example, if you write a cloud deployment toolkit, you can ensure that only one user is attempting to modify a deployment at any given time.


[state_storage]: state_storage.md
