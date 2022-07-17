<!--
Maintainer:   jeffskinnerbox@yahoo.com / www.jeffskinnerbox.me
Version:      1.5.0
-->


<div align="center">
<img src="http://www.foxbyrd.com/wp-content/uploads/2018/02/file-4.jpg" title="These materials require additional work and are not ready for general use." align="center">
</div>


-----

* [How to Use Tags in Ansible Playbook (Examples)](https://www.linuxtechi.com/how-to-use-tags-in-ansible-playbook/)


# Backup a Linux PC to a Synology NAS Using Rsync
* [How I configured my Synology NAS and Linux to use rsync for backups](https://obsolete29.com/posts/2022/04/30/how-i-configured-my-synology-nas-and-linux-to-use-rsync-for-backups/)
* [How do I back up data from a Linux device to my Synology NAS via rsync?](https://kb.synology.com/en-global/DSM/tutorial/How_to_back_up_Linux_computer_to_Synology_NAS)
* [Backup a Linux PC to a Synology NAS using Rsync!](https://www.wundertech.net/how-to-backup-a-linux-pc-to-a-synology-nas-using-rsync/)
* [How to Use rsync on Synology NAS](https://linuxhint.com/use-rsync-synology-nas/)
* [Backup and Restore Your Linux System with rsync](https://averagelinuxuser.com/backup-and-restore-your-linux-system-with-rsync/)



#### Do Full Backup of /home
* [Backup and Restore Your Linux System with rsync](https://averagelinuxuser.com/backup-and-restore-your-linux-system-with-rsync/)

Basically, these three options mean to preserve all the attributes of your files. Owner attributes or permissions will not be modified during the backup process.
-a - archive mode.
-A - preserve Access Control List.
-X - preserve extended attributes.

--delete - this option allows you to make an incremental backup. That means, if it is not your first backup, it will backup only the difference between your source and the destination. So, it will backup only new files and modified files and it will also delete all the files in the backup which were deleted on your system. **Be careful with this option.**

--dry-run - This option simulates the backup. Useful to test its execution.

```bash
# do a dry-run test
sudo rsync --dry-run -aAXv --exclude="lost+found" /media/jeff-admin/c484e1d5-5e9d-4f95-bca9-de500fa3d44e/daily.0/desktop/home/ /home/

# do the restoration for real
sudo rsync -aAXv --exclude="lost+found" /media/jeff-admin/c484e1d5-5e9d-4f95-bca9-de500fa3d44e/daily.0/desktop/home/ /home/

# filesystem status
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           1.6G  2.1M  1.6G   1% /run
/dev/sda6       109G   14G   90G  14% /
tmpfs           7.8G  400M  7.4G   6% /dev/shm
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
/dev/md0        916G  410G  460G  48% /home
/dev/sda3       512M  5.3M  507M   2% /boot/efi
tmpfs           1.6G  4.7M  1.6G   1% /run/user/1000
```



# Fix Desktop Backup Tools

## Restart Synology Backup Processing
I'm using a Synology small office NAS to perfrom hourly backup of my Linux desktop system.
Its a 2-bay [DiskStation DS220+][38] and much of its operation is not impacted by my
refresh of the Ubuntu OS.
Never the less, there is some house keeping to be done.

## Install rsync, grsync, and rsnapshot - DONE
Rsync should already be installed on most Linux system.
You can install it, and the [grsync][04] & [rsnapshot][08] tools, using this command:

```bash
# install rsync, grsync, and rsnapshot
sudo apt-get install rsync grsync rsnapshot
```

#### Step X: Create Backup User and Validate - DONE
On the Linux desktop, you need to assure there is a `backup_user` login,
with a UID of less that 500,
which will run the rsync / rsnapshot utilities
and have `ssh` authentication keys.

>**NOTE:** I choose a UID of 400 so that the `backup_user`
>would not appear on the Ubuntu/Debian login screen list.
>To hide a user from the Ubuntu/Debian login screen list,
>you should be able to add the name to the hidden-users
>list in the file `/etc/lightdm/users.conf`, but there is a [problem][45].
>The is an alternative, and that is to choose a UID value less than 500
>(See the "minimum-uid" in `/etc/lightdm/users.conf`).

```bash
# validate that backup_user login exist with uid of 400
cat /etc/passwd | grep backup_user

# validate that backup_user has a home directory with required tools
ls -a /home/backup_user/
```

#### Step X: Add backup_user to sudo List - DONE
The `backup_user` is not root, and therefore, the utilities it uses for backups
(`rsync` and `rsnapshot`)
can't freely move through the whole directory system , write files, and such.
Again using the [`visudo`][43] command,
edit the [`/etc/sudoers`][44] file by adding the following
to the bottom of the file.

```bash
# start the edit process and do the edits below
sudo visudo /etc/sudoers

# allows this user to not need a password to sudo the specified command(s)
backup_user    ALL=NOPASSWD:    /usr/bin/rsync
backup_user    ALL=NOPASSWD:    /usr/bin/rsnapshot
```

Now check your work:

```bash
# check if your edits took hold
$ sudo cat /etc/sudoers | grep backup_user
backup_user    ALL=NOPASSWD:    /usr/bin/rsync
backup_user    ALL=NOPASSWD:    /usr/bin/rsnapshot
```

A [better approach][50] might be to put the access rules for the backup account in a single file.
In this case, put the rules below in a file call `backup_user` in a directory `/etc/sudoers.d/`.

```bash
# allows this user to not need a password to sudo the specified command(s)
backup_user    ALL=NOPASSWD:    /usr/bin/rsync
backup_user    ALL=NOPASSWD:    /usr/bin/rsnapshot
```

>**NOTE:** Why is there this `/etc/sudoers.d/` directory?
>Changes made to files in `/etc/sudoers.d` remain in place if you upgrade the system.
>This can prevent user lockouts when the system is upgraded.
>Ubuntu/Debian tends to like this behavior.
>Other distributions are using this layout as well.

#### Step X: Increased Security of backup_user Account - DONE
The final step is to lock all this down.
To increase the security of the overall scheme,
on the remote systems and on the local system,
remove the user password from the `backup_user`
and set the shell to a NOOP command.

```bash
# increase security by deleting password and remove login shell
sudo passwd --delete backup_user
sudo usermod -s /sbin/nologin backup_user
```

#### Step X: Start Synology Backup Process
You should be able to now restart your Synology backup NAS device.
Check that backups are created.

#### Step X: Restart Rsnapshot Backup Processing
To get your backup work again,
you should read the document
`/home/jeff/blogging/content/articles/network-backups-via-rsync-and-rsnapshot.md`.
A large fraction of this work is done for you by reclaiming the `/home` directory
and using the scripts within `/home/bachup_user/bin`.
The steps you need to perform, using the documentation as your guide:

1. You'll need to to install `rsync` and related software.
2. Update the `/etc/fstab` file to mount the external drive.
3. Mount the drive and do your first backup, as document, manually
(i.e. `sudo rsnapshot hourly`).
4. To get automated backups running, update the `crontab` file for the
user `backup_user` (if needed), and restart it.




[04]:http://www.opbyte.it/grsync/
[08]:http://www.rsnapshot.org/

[38]:https://www.synology.com/en-us/products/DS220+

[43]:http://www.sudo.ws/sudo/sudoers.man.html
[44]:http://www.sudo.ws/visudo.man.html
[45]:http://www.cyberciti.biz/faq/howto-change-rename-user-name-id/

[50]:https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file

