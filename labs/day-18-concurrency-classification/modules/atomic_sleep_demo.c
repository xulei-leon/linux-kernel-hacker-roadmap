#include <linux/delay.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/spinlock.h>

static DEFINE_SPINLOCK(demo_lock);

static bool trigger_atomic_sleep;
module_param(trigger_atomic_sleep, bool, 0644);
MODULE_PARM_DESC(trigger_atomic_sleep, "Dangerous: call msleep while holding a spinlock");

static int __init atomic_sleep_demo_init(void)
{
	unsigned long flags;

	pr_info("atomic_sleep_demo: loaded trigger_atomic_sleep=%d\n", trigger_atomic_sleep);

	if (trigger_atomic_sleep) {
		pr_alert("atomic_sleep_demo: sleeping while holding spinlock; expect DEBUG_ATOMIC_SLEEP report when enabled\n");
		spin_lock_irqsave(&demo_lock, flags);
		msleep(20);
		spin_unlock_irqrestore(&demo_lock, flags);
	}

	return 0;
}

static void __exit atomic_sleep_demo_exit(void)
{
	pr_info("atomic_sleep_demo: unloaded\n");
}

module_init(atomic_sleep_demo_init);
module_exit(atomic_sleep_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 18 atomic sleep classification demo module");

