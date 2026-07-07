#include <linux/delay.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/workqueue.h>

static struct workqueue_struct *demo_wq;
static struct delayed_work demo_work;

static int delay_ms = 1000;
module_param(delay_ms, int, 0644);
MODULE_PARM_DESC(delay_ms, "Delay before queued work runs");

static int block_ms = 3000;
module_param(block_ms, int, 0644);
MODULE_PARM_DESC(block_ms, "How long the work item sleeps");

static void workqueue_demo_fn(struct work_struct *work)
{
	pr_info("workqueue_demo: execute start block_ms=%d\n", block_ms);
	if (block_ms > 0)
		msleep(block_ms);
	pr_info("workqueue_demo: execute end\n");
}

static int __init workqueue_demo_init(void)
{
	demo_wq = alloc_workqueue("workqueue_demo", WQ_UNBOUND | WQ_MEM_RECLAIM, 1);
	if (!demo_wq)
		return -ENOMEM;

	INIT_DELAYED_WORK(&demo_work, workqueue_demo_fn);
	queue_delayed_work(demo_wq, &demo_work, msecs_to_jiffies(delay_ms));
	pr_info("workqueue_demo: queued delayed work delay_ms=%d block_ms=%d\n",
		delay_ms, block_ms);
	return 0;
}

static void __exit workqueue_demo_exit(void)
{
	cancel_delayed_work_sync(&demo_work);
	destroy_workqueue(demo_wq);
	pr_info("workqueue_demo: unloaded after cancel/drain\n");
}

module_init(workqueue_demo_init);
module_exit(workqueue_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 23 workqueue lifecycle demo module");
